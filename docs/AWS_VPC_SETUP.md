# Setup AWS VPC

Here we create a VPC with public and private subnets (one for each availabilty zone), set up an Internet Gateway, a NAT gateway and routing tables.

## Create a new VPC

Create a new VPC (optionally deleting the default VPC) with the CIDR `10.0.0.0/16`

## Create subnets

Create one public and one private subnet for each availability zone. For example:

*public-1a*

```
10.0.0.0/24
```

*public-1b*

```
10.0.1.0/24
```

*private-1a*

```
10.0.2.0/24
```

*private-1b*

```
10.0.3.0/24
```

## Create an Internet Gateway

The Internet Gateway allows your public subnets to receive traffic from and connect to the Internet. Add an Internet Gateway and attach it to your VPC.

## Create a NAT Gateway

A NAT Gateway allows instances on your private subnets to access the Internet, without allowing inbound traffic. Add a NAT gateway, specifying an IP address from your *pubic* subnet. Allocate a new Elastic IP for the NAT Gateway.

## Set up the Route Tables

### Public Subnets

Add a route table for your *public* subnets with the following rules:

| Destination   | Target       |
| ------------- |------------- |
| `10.0.0.0/16` | local        |
| `0.0.0.0/0`   | `igw-abcdef` |

Where `igw-abcdef` is the ID of your Internet Gateway.

Associate your *public* subnets with the route table. Note this will remove them from the main route table (this is ok).

### Private Subnets

Add a new route table for your *private* subnets or use the existing main route table with the following rules:

| Destination   | Target       |
| ------------- |------------- |
| `10.0.0.0/16` | local        |
| `0.0.0.0/0`   | `nat-abcdef` |

Where `nat-abcdef` is the ID of your NAT Gateway.

Make sure that your private subnets are associated with this route table.
