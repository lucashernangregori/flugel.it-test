package test

import (
	"fmt"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/aws"
	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
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
	//url := "http://" + lbDNSName + "/test1.txt"
	//statusCode, body := helper.HttpGet(t, url, nil)

	// httpTestAction := func() (string, error){
	// 	statusCode, body := helper.HttpGet(t, url, nil)
	// 	if statusCode == expectedStatus {
	// 		logger.Logf(t, "Got expected status code %d from URL %s", expectedStatus, url)
	// 		return body, nil
	// 	 }
	// 	 return "", fmt.Errorf("got status %d instead of the expected %d from %s", statusCode, expectedStatus, url)
	//   }
	// }

	//DoWithRetry(t,"wait until http server is ready",10, time.Duration(2 * time.Minute), httpTestAction)
	// assert.Equal(t, statusCode, 200)
	//assert.Equal(t, body, terraformApplyCurrentTime)
	fileNames := terraform.OutputList(t, terraformOptions, "s3_test_files")
	testURL(t, lbDNSName, fileNames[0], 200, terraformApplyCurrentTime)
}

func testURL(t *testing.T, endpoint string, path string, expectedStatus int, expectedBody string) {
	url := fmt.Sprintf("%s://%s/%s", "http", endpoint, path)
	actionDescription := fmt.Sprintf("Calling %s", url)
	output := retry.DoWithRetry(t, actionDescription, 10, 2*time.Minute, func() (string, error) {
		statusCode, body := http_helper.HttpGet(t, url, nil)
		if statusCode == expectedStatus {
			logger.Logf(t, "Got expected status code %d from URL %s", expectedStatus, url)
			return body, nil
		}
		return "", fmt.Errorf("got status %d instead of the expected %d from %s", statusCode, expectedStatus, url)
	})
	assert.Contains(t, output, expectedBody, "Body should contain expected text")
}
