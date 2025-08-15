resource "aws_vpc" "vpc" {
    cidr_block = "10.0.0.0/20"

    tags = {
        Name = "Vpc-Lab"
    }
}

resource "aws_subnet" "public-1a" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = "10.0.0.0/23"
    map_public_ip_on_launch = true
    availability_zone = "us-east-1a"

    tags = {
        Name = "Sub-Lab-Pub-1a"
    }
}

resource "aws_subnet" "public-1b" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = "10.0.2.0/23"
    map_public_ip_on_launch = true
    availability_zone = "us-east-1b"

    tags = {
      Name = "Sub-Lab-Pub-1b"
    }
}

resource "aws_subnet" "privada-1c" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = "10.0.4.0/23"
    availability_zone = "us-east-1c"

    tags = {
        Name = "Sub-Lab-Priv-1c"
    }
}

resource "aws_subnet" "privada-1d" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = "10.0.6.0/23"
    availability_zone = "us-east-1d"

    tags = {
      Name = "Sub-Lab-Priv-1d"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id

    tags = {
      Name = "Internet-Gateway-Terraform"
    }
}

resource "aws_route_table" "rtb-pub" {
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
      Name = "Rtb-Pub-Terraform"
    }
}

#Elastic IP para NAT GATEWAY

resource "aws_eip" "nat_eip" {
    domain = "vpc"

    tags = {
      Name = "Eip-Nat-Terraform"
    }  
}

resource "aws_nat_gateway" "nat" {
    allocation_id = aws_eip.nat_eip.id
    subnet_id = aws_subnet.public-1a.id

    tags = {
      Name = "Nat-Gateway-Terraform"
    }

    depends_on = [ aws_internet_gateway.igw ]
}

resource "aws_route_table" "rtb-priv" {
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat.id
    }

    tags = {
      Name = "Rtb-Priv-Terraform"
    }
}

#Associar das subnets privadas à route table privada

resource "aws_route_table_association" "priv-1c" {
    subnet_id = aws_subnet.privada-1c.id
    route_table_id = aws_route_table.rtb-priv.id
}

resource "aws_route_table_association" "priv-1d" {
    subnet_id =  aws_subnet.privada-1d.id
    route_table_id = aws_route_table.rtb-priv.id
  
}

#Associar das subnets publica à route table pública

resource "aws_route_table_association" "pub-1a" {
    subnet_id = aws_subnet.public-1a.id
    route_table_id = aws_route_table.rtb-pub.id
  
}

resource "aws_route_table_association" "pub-1b" {
    subnet_id = aws_subnet.public-1b.id
    route_table_id = aws_route_table.rtb-pub.id
  
}
