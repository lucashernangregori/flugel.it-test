package main

import (
	"fmt"

	ec2 "github.com/aws/aws-sdk-go/service/ec2"
)

func main() {
	// resolver := endpoints.DefaultResolver()
	// partitions := resolver.(endpoints.EnumPartitions).Partitions()

	// for _, p := range partitions {
	// 	fmt.Println("Regions for", p.ID())
	// 	for id, _ := range p.Regions() {
	// 		fmt.Println("*", id)
	// 	}

	// 	fmt.Println("Services for", p.ID())
	// 	for id, _ := range p.Services() {
	// 		fmt.Println("*", id)
	// 	}
	// }

	// myCustomResolver := func(service, region string, optFns ...func(*endpoints.Options)) (endpoints.ResolvedEndpoint, error) {
	// 	if service == endpoints.S3ServiceID {
	// 		return endpoints.ResolvedEndpoint{
	// 			URL:           "s3.custom.endpoint.com",
	// 			SigningRegion: "custom-signing-region",
	// 		}, nil
	// 	}

	// 	return endpoints.DefaultResolver().EndpointFor(service, region, optFns...)
	// }

	// partitions := myCustomResolver.(endpoints.EnumPartitions).Partitions()
	// sess := session.Must(session.NewSession(&aws.Config{
	// 	Region:           aws.String("us-east-1"),
	// 	EndpointResolver: endpoints.ResolverFunc(myCustomResolver),
	// }))

	requestParam := ec2.DescribeLocalGatewaysInput{
		// DryRun: *false,
	}
	result := ec2.DescribeLocalGateways(requestParam)
	for _, p := range result {
		fmt.Println("Regions for", p.ID())
	}
}
