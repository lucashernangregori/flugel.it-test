output "vpc_id" {
  value = aws_vpc.test.vpc
}

output "public_subnets" {
    value = [aws_subnet.test_public.*.id]
} 

output "private_subnets" {
    value = [aws_subnet.test_private.*.id]
} 