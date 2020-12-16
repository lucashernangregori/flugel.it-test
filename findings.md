Changing the region on the test, kill the test, because terraform tries to refresh the state from the production state file instead of a new test state file.(And looks for resources created on the original region).

In order to use different state files, we must use the following code on terraformOptions in our *_test.go file:

BackendConfig: map[string]interface{}{
			"path": "./testBackend.tfstate",
		},


But this alone does not works, also, in our terraform folder, we must specify a backend config. Like this:
terraform {
  required_version = ">= 0.13.2"
  backend "local" {}
}

This allows terratest to override the backend.
But there is a last problem: after running the tests, the backend get stuck pointing to the test backend file location.
We can see that on the .terraform folder on the terraform.tfstate file.

Beware, it can destroy my production settings. We must get the state matter right!