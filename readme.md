# flugel.it Challenge

### This repo contains TERRAFORM code which does the following actions:
### *Creates a vpc, two public subnets and two private subnets on two different availability zones. Private subnets have a Nat gateway
### *Creates a S3 bucket with two files with the timestamp of the moment when the code is executed.
### *Creates an s3 service endpoint to route requests without going out to the internet. The routing is on private subnets.
### *Set up permission and roles to secure s3 bucket
### *Creates 2 ec2 instances on private subnets which clones a repo with aditional files (more details on its section) ### *Install docker and runs traefik v2.3.6 image with custom config and plugins
### *Set up traefik to forward requests using iam_role via plugin
### *Creates an ALB with a target group pointing to the ec2 instances (internet facing ALB must be sitting on two public subnets with different AZs in order to be created)
### *Optionally creates an ec2 instance to use as a bastion host form debugging purposes
### The S3 bucket is versioned and has a policy which only allows the user cloud_user to perform actions on it. This is coded that way in order to follow the best practices that Super-Linter recommends.

### The repo also contains tests for the TERRAFORM code. Those tests use the TERRATEST GO library in order to perform its magic.
### The tests checks for the existence of the bucket, the versioned settings, if it has a policy attached and finally the files and its contents to match the desired timestamp.
### There is an additional E2E test, which creates all the infrastructure already detailed and makes a request to the ALB to get the s3 file trough traefik running on ec2 instances. In order to test that we are reaching the two instances, it checks for 6 status code 200. Then it checks for the file content to be correct.

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
## Traefik Custom Plugin
Sometimes we might think that attaching a role to an ec2 instance with the proper permissions is enough to make a successful s3 request to a protected bucket.
But thats only the case when we do that request from aws cli or aws sdk.
For every other petition, we need to sign that request. We can use the v2 or the v4 method. (https://docs.aws.amazon.com/AmazonS3/latest/dev/S3_Authentication2.html)
For instance, if we issue a plain curl command we will get a 403 status code. We need to add the correct headers to get a 200 status code.
With traefik we must do the same. I doesn't have support out of the box. So I wrote a custom plugin to make requests work as intended.
To use the plugin we need to get traefik pilot token (https://doc.traefik.io/traefik/plugins/)
We use the plugin on dev mode, in order to not to publish to github and appear on pilot store. The dev mode has the limitation that only works for 30 minutes, then it shuts down the server. But this is enough for the MVP.
We use traefik with two config files: one is static configuration, called traefik.yml and the other is dynamic configuration, called dynamic.yml.
Static configuration can only be applied at startup, in that file we specify our token and our plugin path.
In the dynamic configuration, we set the router, the services and the middleware (in our case, the plugin)
All of these configurations are pulled from my github repo https://github.com/lucashernangregori/traefik-plugindemo on the ec2 instances boot via user_data.
On that repo the plugin resides. Along with a docker file to copy the plugin to the image.
There is a build.sh bash script that builds the image and runs the container.
In the ec2 user_data we have a template for dynamic.yml in order to inject different bucket names and s3 regions for testing and flexibility purposes.


Enjoy!