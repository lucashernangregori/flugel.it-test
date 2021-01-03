package test

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/retry"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestE2EDummy(t *testing.T) {
	t.Parallel()

	vpcCidr := "10.10.0.0/16"
	privateSubnetCidr := []string{"10.10.1.0/24", "10.10.0.0/24"}
	publicSubnetCidr := []string{"10.10.2.0/24", "10.10.3.0/24"}
	awsRegion := "us-west-2"
	s3Endpoint := "com.amazonaws." + awsRegion + ".s3"
	expectedBucketName := fmt.Sprintf("flugel.it.lucashernangregori.com.terratest-%s", strings.ToLower(random.UniqueId()))
	s3IamRoleName := fmt.Sprintf("s3_reader-%s", strings.ToLower(random.UniqueId()))
	traefikInstanceProfile := fmt.Sprintf("traefik-%s", strings.ToLower(random.UniqueId()))
	traefikInstancesCount := 2

	_fixturesDir := test_structure.CopyTerraformFolderToTemp(t, "../tfCode/s3Proxy", ".")
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: _fixturesDir,
		BackendConfig: map[string]interface{}{
			"path": "./testBackend.tfstate",
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
		Vars: map[string]interface{}{
			"vpc_cidr":                 vpcCidr,
			"public_subnets":           publicSubnetCidr,
			"private_subnets":          privateSubnetCidr,
			"enable_nat":               true,
			"s3_endpoint":              s3Endpoint,
			"region_master":            awsRegion,
			"bucket_name":              expectedBucketName,
			"s3_iam_role":              s3IamRoleName,
			"traefik_instance_profile": traefikInstanceProfile,
			"traefik_instances_count":  traefikInstancesCount,
		},
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	publicSubnetID := terraform.OutputList(t, terraformOptions, "public_subnets")
	privateSubnetID := terraform.OutputList(t, terraformOptions, "private_subnets")
	vpcID := terraform.Output(t, terraformOptions, "vpc_id")

	subnets := aws.GetSubnetsForVpc(t, vpcID, awsRegion)

	totalSubnets := len(privateSubnetCidr) + len(publicSubnetCidr)
	require.Equal(t, totalSubnets, len(subnets))
	// Verify if the network that is supposed to be public is really public
	for _, subnet := range publicSubnetID {
		assert.True(t, aws.IsPublicSubnet(t, subnet, awsRegion))
	}
	// Verify if the network that is supposed to be private is really private
	for _, subnet := range privateSubnetID {
		assert.False(t, aws.IsPublicSubnet(t, subnet, awsRegion))
	}
	terraformApplyCurrentTime := terraform.Output(t, terraformOptions, "current_time")
	lbDNSName := terraform.Output(t, terraformOptions, "lb_dns_name")

	fileNames := terraform.OutputList(t, terraformOptions, "s3_test_files")
	testURL(t, lbDNSName, fileNames[0], 200, terraformApplyCurrentTime, 6)
}

func testURL(t *testing.T, endpoint string, path string, expectedStatus int, expectedBody string, minHits int) {
	hits := 0
	url := fmt.Sprintf("%s://%s/%s", "http", endpoint, path)
	actionDescription := fmt.Sprintf("Calling %s", url)
	output := retry.DoWithRetry(t, actionDescription, 100, 30*time.Second, func() (string, error) {
		body, err := func() (string, error) {
			defer func() {
				if r := recover(); r != nil {
					fmt.Println("panic occured and cached: ", r)
				}
			}()

			//we use our own client, because terratest http_utils panics on connection refused and stops test execution
			client := http.Client{
				// By default, Go does not impose a timeout, so an HTTP connection attempt can hang for a LONG time.
				Timeout: 10 * time.Second,
			}

			resp, err := client.Get(url)
			if err != nil {
				return "", fmt.Errorf("error on http get")
			}
			defer resp.Body.Close()
			body, err2 := ioutil.ReadAll(resp.Body)
			if err2 != nil {
				return "", fmt.Errorf("error reading http body")
			}

			var response httpResponse
			response.Body = strings.TrimSpace(string(body))
			response.StatusCode = resp.StatusCode
			if response.StatusCode == expectedStatus {
				logger.Logf(t, "Got expected status code %d from URL %s", expectedStatus, url)
				hits++
			}

			if hits >= minHits {
				logger.Logf(t, "Got expected hits count: %d", minHits)
				return response.Body, nil
			}

			return "", fmt.Errorf("got status %d instead of the expected %d from %s", response.StatusCode, expectedStatus, url)
		}()
		return body, err
	})
	assert.Contains(t, output, expectedBody, "Body should contain expected text")
}

type httpResponse struct {
	Body       string
	StatusCode int
}
