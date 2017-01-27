# Setup AWS VPC with public and private subnets

1. Allocate an elastic IP address which will be used for your NAT Gateway for your private subnet. The NAT Gateway is used to enable instances in a private subnet to connect to the Internet or other AWS services, but prevent the Internet from initiating a connection with those instances.
2. Create a new VPC using the wizard with a public and private subnet. Assign the elastic IP that you created above for the NAT Gateway.
3. Add an additional public and private subnet in a different availability zone. (In total you should have 4 subnets in your VPC. 1 private, and 1 public for each availability zone.
4. Connect both of your public subnets to the internet gateway, and both of your private subnets to the NAT Gateway.
