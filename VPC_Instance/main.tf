resource "aws_vpc" "myvpc" {
    cidr_block = var.cidr
    tags = {
      "NAME" = "MYVPC"
    }
  
}

#public subnet
resource "aws_subnet" "subnet1" {
  vpc_id = aws_vpc.myvpc.id
  availability_zone = "us-east-1"
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true

  tags = {
    "NAME" = "MYSUB1"
  }
}

#private subnet
resource "aws_subnet" "subnet2" {
    vpc_id = aws_vpc.myvpc.id
    availability_zone = "us-east-1"
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = false

    tags = {
      "NAME" = "MYSUB2"
    }
  
}

#internet gateway
resource "aws_internet_gateway" "igw" {
 vpc_id = aws_vpc.myvpc.id

 tags = {
   "NAME" = "MYIGW"
 }
  
}

#route table
resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

 #associating routing table to public subnet
  resource "aws_route_table_association" "RTA" {
    subnet_id = aws_subnet.subnet1.id
    route_table_id = aws_route_table.RT.id
    
  }

#elastic ip for NAT gateway
resource "aws_eip" "Natgateway_eip" {
    vpc = true

    tags = {
      "NAME" = "MYEIP"
    }
  
}

#NAT gateway
resource "aws_nat_gateway" "NATgateway" {
    allocation_id = aws_eip.Natgateway_eip.id
    subnet_id = aws_subnet.subnet1.id

    tags = {
      "NAME" = "MYNAT"
    }
  
}

#NAT Gateway route table
resource "aws_nat_gateway_route_table" "NATroutetable" {
    vpc_id = aws_vpc_myvpc.id

    route {
        cidr_block = "0.0.0.0/0"
        aws_nat_gateway = aws_nat_gateway.NATgateway.id
    }
  
}

resource "aws_route_table_association" "instance" {
  subnet_id = aws_subnet.subnet1.id
  route_table_id =aws_nat_gateway_route_table.NATroutetable.id
}


#security group
resource "aws_security_group" "SG" {
    name = "security group"
    vpc_id = aws_vpc.myvpc.id

      ingress = {
        description = "HTTP"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

 ingress {
       description = "SSH"
       from_port   = 22
       to_port     = 22
       protocol    = "tcp"
       cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
       from_port   = 0
       to_port     = 0
       protocol    = "-1"
       cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    "NAME" = "MYSG"
    }
}



resource "aws_instance" "myec2" {
  ami = var.aws_ami
  instance_type = var.aws_instance
  subnet_id = aws_subnet.subnet2.id
  tags = {
    "Name" = "MyInstance"
  }
}

