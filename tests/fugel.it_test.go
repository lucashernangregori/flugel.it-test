package test

import (
	"fmt"
	"strings"
	"testing"
	 "os"
	 "log"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraformCode(t *testing.T) {
	fmt.Print("hola")
	file, err := os.Open("test2")
    		if err != nil {
        	log.Fatal(err)
    	}

    	fmt.Print(file)
	
	fmt.Println("Shell:", os.Getenv("MY_SECRET"))
	fmt.Println("Shell:", os.Getenv("AWS_SECRET_ACCESS_KEY"))
	for _, e := range os.Environ() {
		pair := strings.SplitN(e, "=", 2)
		fmt.Printf("%s: %s\n", pair[0], pair[1])
    	}
	
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
	aws.AssertS3BucketPolicyExists(t, awsRegion, expectedBucketName)
	aws.AssertS3BucketVersioningExists(t, awsRegion, expectedBucketName)

	for _, fileName := range fileNames {
		fileContent := aws.GetS3ObjectContents(t, awsRegion, expectedBucketName, fileName)
		assert.Equal(t, fileContent, terraformApplyCurrentTime)
	}
}
