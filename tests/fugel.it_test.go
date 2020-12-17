package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	// "github.com/gruntwork-io/terratest@v0.31.1/modules/aws"
	// "github.com/gruntwork-io/terratest@v0.31.1/modules/random"
	// "github.com/gruntwork-io/terratest@v0.31.1/modules/terraform"
	// "github.com/stretchr/testify@v1.4.0/assert"
)

func TestTerraformCode(t *testing.T) {
	t.Parallel()

	expectedBucketName := fmt.Sprintf("flugel.it.lucashernangregori.com.terratest-%s", strings.ToLower(random.UniqueId()))
	awsRegion := "us-west-2"

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../tfCode",
		BackendConfig: map[string]interface{}{
			"path": "./testBackend.tfstate",
		},
		Vars: map[string]interface{}{
			"bucket_name":   expectedBucketName,
			"region_master": awsRegion,
		},
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	terraformApplyCurrentTime := terraform.Output(t, terraformOptions, "current_time")
	fileNames := terraform.OutputList(t, terraformOptions, "s3_test_files")

	aws.AssertS3BucketExists(t, awsRegion, expectedBucketName)

	for _, fileName := range fileNames {
		fileContent := aws.GetS3ObjectContents(t, awsRegion, expectedBucketName, fileName)
		assert.Equal(t, fileContent, terraformApplyCurrentTime)
	}
}
