package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"

	"github.com/stretchr/testify/assert"
)

func TestTerraformCode(t *testing.T) {
	t.Parallel()

	expectedBucketName := fmt.Sprintf("flugel.it.lucashernangregori.com.terratest-%s", strings.ToLower(random.UniqueId()))
	s3IamRoleName := fmt.Sprintf("s3_reader-%s", strings.ToLower(random.UniqueId()))
	awsRegion := "us-west-2"

	_fixturesDir := test_structure.CopyTerraformFolderToTemp(t, "../tfCode/s3Proxy/modules/s3Bucket", ".")
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: _fixturesDir,
		BackendConfig: map[string]interface{}{
			"path": "./testBackend.tfstate",
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
		Vars: map[string]interface{}{
			"bucket_name": expectedBucketName,
			"s3_iam_role": s3IamRoleName,
		},
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	terraformApplyCurrentTime := terraform.Output(t, terraformOptions, "current_time")
	fileNames := terraform.OutputList(t, terraformOptions, "s3_test_files")

	aws.AssertS3BucketExists(t, awsRegion, expectedBucketName)
	aws.AssertS3BucketPolicyExists(t, awsRegion, expectedBucketName)
	aws.AssertS3BucketVersioningExists(t, awsRegion, expectedBucketName)

	for _, fileName := range fileNames {
		fileContent := aws.GetS3ObjectContents(t, awsRegion, expectedBucketName, fileName)
		assert.Equal(t, fileContent, terraformApplyCurrentTime)
	}
}
