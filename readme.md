# flugel.it Challenge

### This repo contains TERRAFORM code which creates a S3 bucket with two files with the timestamp of the moment when the code is executed.
### The S3 bucket is versioned and has a policy which only allows the user cloud_user to perform actions on it. This is coded that way in order to follow the best practices that Super-Linter recommends.

### The repo also contains tests for the TERRAFORM code. Those tests use the TERRATEST GO library in order to perform its magic.
### The tests checks for the existence of the bucket, the versioned settings, if it has a policy attached and finally the files and its contents to match the desired timestamp.

### Finally the repo contains a file to use github automation: Github Actions which is described later in this readme.

In order to run the infrastructure automation and its tests, you must download TERRAFORM 0.14 or newer (https://www.terraform.io/downloads.html)
You must have an aws authentication schema in place (https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication)
You need to be authenticated with an user named: cloud_user
The username is hardcoded in the iam policy resource "first_bucket_restricted" because the code is hosted in a public repository and is a security issue to print the ARN of the user dinamicaly using data.aws_caller_identity.current.arn

You must install GO to run the tests with TERRATEST. Use version 1.14 or newer (https://golang.org/dl/)

## Running the tests
Issue the following commands from the root of the repo
```
cd tests
```

To download the dependencies:
```
go get -v
```

To run the tests 
```
go test -v -count=1
```

the count parameter set to 1, means that we disable test caching in order to not get false results (https://golang.org/pkg/cmd/go/internal/test/)

## Running Infrastructure Automation
Issue the following commands from the root of the repo
```
cd tfCode
terraform init
```

To list the infrastructure objects to be created:
```
terraform plan
```

If everything is ok, you impact the changes with:
```
terraform apply
```

You have to write "yes" in order to continue

When you are done, you can destroy the resources created with:
```
terraform destroy
```
Again, you have to write "yes" in order to continue

## Github Actions
The testAction.yml file located on .\github\workflows will be used by github when we do a push or pull request.
It will use Super-Linter to check the GO code and the TERRAFORM code.
After that it will run the tests the the same way we described in the "Running the tests" section. With the exception that the GO modules dependencies are cached.
If you fork the repo, you must set up your aws credentials. In your github repo settings there is an "secrets" option (https://github.com/YOURUSERNAME/YOURREPONAME/settings/secrets/actions).
![Alt text](docs/githubSecret.png?raw=true "Secrets")
In that section you must set a new repository secret named "TEST_AKEY" with your cloud_user Access Key.
And another secret named TEST_SKEY with your cloud_user Secret Access Key.

## Super-Linter
This github actions artifact, scans the code for errors with its default ruleset. If it catches one, it stops the build.
Sometimes we get this error in GO files:
```
File is not `goimports`-ed (goimports)
```
We can fix that with this command:
```
gofmt -w yourcode.go
```

Sometimes we get this error:
```
cannot find package \"github.com/gruntwork-io/terratest/modules/terraform\" in any of:
	/usr/lib/go/src/github.com/gruntwork-io/terratest/modules/terraform (from $GOROOT)
  /github/home/go/src/github.com/gruntwork-io/terratest/modules/terraform (from $GOPATH))
```
This means that Super-Linter container doesn't have access to our GO modules directory.
We must copy our modules folder to the directory that the container will use as a volume.
The container runs with this option:
```
-v "/home/runner/work/_temp/_github_home":"/github/home"
```

The command to copy the files is specified in the testAction.yml file
```
cp -R ~/go /home/runner/work/_temp/_github_home/go
```

Enjoy!!!