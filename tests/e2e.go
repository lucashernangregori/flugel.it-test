package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestE2E(t *testing.T) {
	t.Parallel()

	// Give the VPC and the subnets correct CIDRs
	vpcCidr := "10.10.0.0/16"
	privateSubnetCidr := []string{"10.10.1.0/24"}
	publicSubnetCidr := []string{"10.10.2.0/24"}
	awsRegion := "us-west-2"
	s3Endpoint := "com.amazonaws." + awsRegion + ".s3"

	_fixturesDir := test_structure.CopyTerraformFolderToTemp(t, "../tfCode/s3Proxy/modules/networking", ".")
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: _fixturesDir,
		BackendConfig: map[string]interface{}{
			"path": "./testBackend.tfstate",
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
		Vars: map[string]interface{}{
			"vpc_cidr":        vpcCidr,
			"public_subnets":  publicSubnetCidr,
			"private_subnets": privateSubnetCidr,
			"enable_nat":      true,
			"s3_endpoint":     s3Endpoint,
		},
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	publicSubnetID := terraform.OutputList(t, terraformOptions, "public_subnets")
	privateSubnetID := terraform.OutputList(t, terraformOptions, "private_subnets")
	vpcID := terraform.Output(t, terraformOptions, "vpc_id")

	subnets := aws.GetSubnetsForVpc(t, vpcID, awsRegion)

	require.Equal(t, 2, len(subnets))
	// Verify if the network that is supposed to be public is really public
	for _, subnet := range publicSubnetID {
		assert.True(t, aws.IsPublicSubnet(t, subnet, awsRegion))
	}
	// Verify if the network that is supposed to be private is really private
	for _, subnet := range privateSubnetID {
		assert.False(t, aws.IsPublicSubnet(t, subnet, awsRegion))
	}

}
