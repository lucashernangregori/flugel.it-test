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

	demo := &ec2.EC2{}

	//max := int64(100)
	dry := false
	var req ec2.DescribeLocalGatewaysInput
	req.DryRun = &dry
	// requestParam := ec2.DescribeLocalGatewaysInput{
	// 	// DryRun: *false,
	// 	MaxResults: &max,
	// }

	//requestParamIndirection := &requestParam
	result, _ := demo.DescribeLocalGateways(&req)

	for _, p := range result.LocalGateways {
		fmt.Println(p.LocalGatewayId)
	}
}
