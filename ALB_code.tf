#This Terraform Code Deploys Basic VPC Infra.
provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.aws_region}"
}

# resource "aws_vpc" "default" {
#     cidr_block = "${var.vpc_cidr}"
#     enable_dns_hostnames = true
#     tags = {
#         Name = "${var.vpc_name}"
# 	Owner = "Sree"
#     }
# }

# resource "aws_internet_gateway" "default" {
#     vpc_id = "${aws_vpc.default.id}"
# 	tags = {
#         Name = "${var.IGW_name}"
#     }
# }

# resource "aws_subnet" "subnet1-public" {
#     vpc_id = "${aws_vpc.default.id}"
#     cidr_block = "${var.public_subnet1_cidr}"
#     availability_zone = "us-east-1a"

#     tags = {
#         Name = "${var.public_subnet1_name}"
#     }
# }

# resource "aws_subnet" "subnet2-public" {
#     vpc_id = "${aws_vpc.default.id}"
#     cidr_block = "${var.public_subnet2_cidr}"
#     availability_zone = "us-east-1b"

#     tags = {
#         Name = "${var.public_subnet2_name}"
#     }
# }

# resource "aws_subnet" "subnet3-public" {
#     vpc_id = "${aws_vpc.default.id}"
#     cidr_block = "${var.public_subnet3_cidr}"
#     availability_zone = "us-east-1c"

#     tags = {
#         Name = "${var.public_subnet3_name}"
#     }
	
# }


# resource "aws_route_table" "terraform-public" {
#     vpc_id = "${aws_vpc.default.id}"

#     route {
#         cidr_block = "0.0.0.0/0"
#         gateway_id = "${aws_internet_gateway.default.id}"
#     }

#     tags = {
#         Name = "${var.Main_Routing_Table}"
#     }
# }

# resource "aws_route_table_association" "terraform-public" {
#     subnet_id = "${aws_subnet.subnet1-public.id}"
#     route_table_id = "${aws_route_table.terraform-public.id}"
# }



resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = "vpc-0ce68cc2f14bcbcec"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    }
}

 vpc_id             = "vpc-0ce68cc2f14bcbcec"
  subnets            = ["subnet-015d4a440358da2f7", "subnet-0e99eccf4e09c4a5f"]
  security_groups    = ["allow_all"]
  
  access_logs = {
    bucket = "my-alb-logs"
  }

  target_groups = [
    {
      name_prefix      = "pref-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    }
  ]

#   https_listeners = [
#     {
#       port               = 443
#       protocol           = "HTTPS"
#       certificate_arn    = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"
#       target_group_index = 0
#     }
#   ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    Environment = "Test"
  }
}

# data "aws_ami" "my_ami" {
#      most_recent      = true
#      #name_regex       = "^mavrick"
#      owners           = ["721834156908"]
# }


resource "aws_instance" "web-1" {
    ami = "ami-04b2519c83e2a7ea5"
    availability_zone = "ap-south-1"
    instance_type = "t2.micro"
    key_name = "keypair_mumbai"
    subnet_id = "subnet-015d4a440358da2f7"
    vpc_security_group_ids = ["${aws_security_group.allow_all.id}"]
    associate_public_ip_address = true
    user_data = << EOF
		#!/bin/bash
        sudo yum update -y
		sudo yum install httpd -y
		sudo service httpd start
        sudo chkconfig httpd on
        sudo cd /var/www/html
        echo '<html><h1>Web Server 1</h1></html>'  > /var/www/html/index.html
    tags = {
        Name = "Server-1"
        Env = "Prod"
        Owner = "nj"
	CostCenter = "ABCD"
    }
}


resource "aws_instance" "web-2" {
    ami = "ami-04b2519c83e2a7ea5"
    availability_zone = "ap-south-1"
    instance_type = "t2.micro"
    key_name = "keypair_mumbai"
    subnet_id = "subnet-0e99eccf4e09c4a5f"
    vpc_security_group_ids = ["${aws_security_group.allow_all.id}"]
    associate_public_ip_address = true	
    user_data = << EOF
		#!/bin/bash
        sudo yum update -y
		sudo yum install httpd -y
		sudo service httpd start
        sudo chkconfig httpd on
        sudo cd /var/www/html
        echo '<html><h1>Web Server 2</h1></html>'  > /var/www/html/index.html
    tags = {
        Name = "Server-2"
        Env = "Prod2"
        Owner = "nj-1"
	CostCenter = "ABCDef"
    }
}

##output "ami_id" {
#  value = "${data.aws_ami.my_ami.id}"
#}
#!/bin/bash
# echo "Listing the files in the repo."
# ls -al
# echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++"
# echo "Running Packer Now...!!"
# packer build -var=aws_access_key=AAAAAAAAAAAAAAAAAA -var=aws_secret_key=BBBBBBBBBBBBB packer.json
# echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++"
# echo "Running Terraform Now...!!"
# terraform init
# terraform apply --var-file terraform.tfvars -var="aws_access_key=AAAAAAAAAAAAAAAAAA" -var="aws_secret_key=BBBBBBBBBBBBB" --auto-approve
