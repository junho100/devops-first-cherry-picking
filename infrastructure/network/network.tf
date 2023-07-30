resource "aws_vpc" "app_vpc" {
  cidr_block = "192.168.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "terry-vpc"
  }
}

resource "aws_internet_gateway" "app_internet_gateway" {
  tags = {
    Name = "terry-igw"
  }
}

resource "aws_internet_gateway_attachment" "app_internet_gateway_attachment" {
    internet_gateway_id = aws_internet_gateway.app_internet_gateway.id
    vpc_id = aws_vpc.app_vpc.id
}

resource "aws_route_table" "app_public_route_table" {
    vpc_id = aws_vpc.app_vpc.id
    tags = {
        Name = "terry-public-rt"
    }
}

resource "aws_route_table" "app_private_route_table1" {
    vpc_id = aws_vpc.app_vpc.id
    tags = {
        Name = "terry-private-rt-1"
    }
}

resource "aws_route_table" "app_private_route_table2" {
    vpc_id = aws_vpc.app_vpc.id
    tags = {
        Name = "terry-private-rt-2"
    }
}

resource "aws_route" "app_public_route" {
    route_table_id = aws_route_table.app_public_route_table.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app_internet_gateway.id
}

resource "aws_route" "app_private_route1" {
    route_table_id = aws_route_table.app_private_route_table1.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.app_nat_gateway1.id
}

resource "aws_route" "app_private_route2" {
    route_table_id = aws_route_table.app_private_route_table2.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.app_nat_gateway2.id
}

resource "aws_nat_gateway" "app_nat_gateway1" {
    allocation_id = aws_eip.app_nat_gateway_eip1.allocation_id
    subnet_id = aws_subnet.app_public_subnet1.id
    tags = {
        Name = "terry-nat-1"
    }
}

resource "aws_nat_gateway" "app_nat_gateway2" {
    allocation_id = aws_eip.app_nat_gateway_eip2.allocation_id
    subnet_id = aws_subnet.app_public_subnet2.id
    tags = {
        Name = "terry-nat-2"
    }
}

resource "aws_eip" "app_nat_gateway_eip1" {
    domain = "vpc"
    tags = {
        Name = "terry-nat-eip-1"
    }
}

resource "aws_eip" "app_nat_gateway_eip2" {
    domain = "vpc"
    tags = {
        Name = "terry-nat-eip-2"
    }
}

resource "aws_subnet" "app_public_subnet1" {
    vpc_id = aws_vpc.app_vpc.id
    map_public_ip_on_launch = true
    availability_zone = "ap-northeast-2a"
    cidr_block = "192.168.0.0/18"
    tags = {
      Name = "terry-public-subnet-1"
    }
}

resource "aws_subnet" "app_public_subnet2" {
    vpc_id = aws_vpc.app_vpc.id
    map_public_ip_on_launch = true
    availability_zone = "ap-northeast-2c"
    cidr_block = "192.168.64.0/18"
    tags = {
      Name = "terry-public-subnet-2"
    }
}

resource "aws_subnet" "app_private_subnet1" {
  vpc_id = aws_vpc.app_vpc.id
  cidr_block = "192.168.128.0/18"
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "terry-private-subnet-1"
    Type = "subnet"
  }
}

resource "aws_subnet" "app_private_subnet2" {
  vpc_id = aws_vpc.app_vpc.id
  cidr_block = "192.168.192.0/18"
  availability_zone = "ap-northeast-2c"
  tags = {
    Name = "terry-private-subnet-2"
    Type = "subnet"
  }
}

resource "aws_route_table_association" "app_public_subnet_rt_association1" {
    subnet_id = aws_subnet.app_public_subnet1.id
    route_table_id = aws_route_table.app_public_route_table.id
}

resource "aws_route_table_association" "app_public_subnet_rt_association2" {
    subnet_id = aws_subnet.app_public_subnet2.id
    route_table_id = aws_route_table.app_public_route_table.id
}

resource "aws_route_table_association" "app_private_subnet_rt_association1" {
    subnet_id = aws_subnet.app_private_subnet1.id
    route_table_id = aws_route_table.app_private_route_table1.id
}

resource "aws_route_table_association" "app_private_subnet_rt_association2" {
    subnet_id = aws_subnet.app_private_subnet2.id
    route_table_id = aws_route_table.app_private_route_table2.id
}

data "aws_subnets" "public_and_private_subnet_ids" {
    filter {
        name   = "vpc-id"
        values = [aws_vpc.app_vpc.id]
    }

    tags = {
        Type = "subnet"
    }
}

output "vpc_id" {
    value = aws_vpc.app_vpc.id
}

output "subnet_ids" {
    value = data.aws_subnets.public_and_private_subnet_ids.ids
}