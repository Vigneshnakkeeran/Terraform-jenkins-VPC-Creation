 provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAQP77VNX23F7QUFPL"
  secret_key = "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"
}
# Creating VPC,name,CIDR 
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "myvpc"
  }
}
# Creating Public Subnets in VPC
resource "aws_subnet" "pubsub" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "publicsubnet"
  }
}
# Creating Private Subnets in VPC
resource "aws_subnet" "prisub" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "privatesubnet"
  }
}

# Creating Internet Gateway in AWS VPC
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "myinternetgateway"
  }
}

# Creating Public route table and map with Internet Gateway
resource "aws_route_table" "pubroute" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
  
  tags = {
    Name = "publicroute"
  }
}
# Creating Private route table and map with NAT Gateway
resource "aws_route_table" "priroute" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw.id
  }
  
  tags = {
    Name = "privateroute"
  }
}

# Creating Route Associations public subnets
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.pubsub.id
  route_table_id = aws_route_table.pubroute.id
}
# Creating Route Associations private subnets
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.prisub.id
  route_table_id = aws_route_table.priroute.id
}
# Creating Elastic IP
resource "aws_eip" "elasticip" {
  vpc      = true
}

# Creating Nat Gateway
resource "aws_eip" "nat" {
  vpc = true
}
resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.elasticip.id
  subnet_id     = aws_subnet.pubsub.id
  depends_on    = [aws_internet_gateway.IGW]
  
  tags = {
    Name = "mynatgateway"
  }
}

# Creating Public Secuirity Group
resource "aws_security_group" "allow_ptls" {
  name        = "allow_ptls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "SSH"   
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  
  }
  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }
  egress {
    description      = "All Traffic"
    from_port        = 0
    to_port          = 65535
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  tags = {
    Name = "my_public_security"
  }
}
# Creating Private Secuirity Group
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }
  ingress {
    description      = "SSH"   
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  
  }
  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }  
    
  egress {
    from_port        = 0
    to_port          = 65535
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
   
  }

  tags = {
    Name = "my_private_security"
  }
}
#Creating EC2 Instace
resource "aws_instance" "Ec2" {
    ami = "ami-026b57f3c383c2eec" #us-east-1
    instance_type ="t2.micro"
    key_name = "oct18"
    subnet_id = aws_subnet.pubsub.id
    vpc_security_group_ids = ["sg-0157d819988cc1bdf"]
    tags = {
        Name ="linux1 Ec2"
    }
}
resource "aws_instance" "Ec21" {
    ami = "ami-026b57f3c383c2eec" #us-east-1
    instance_type ="t2.micro"
    key_name = "oct18"
    subnet_id = aws_subnet.prisub.id
    vpc_security_group_ids = ["sg-09af9c8b3a79e0f41"]
    tags = {
        Name ="linux2 Ec2"
    }
}
