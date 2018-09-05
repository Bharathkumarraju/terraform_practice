#################################################
#     Variables
#################################################

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}


variable "key_name" {
  default = "hanumankeys"
                    }

variable "network_address_space" {
  default = "10.1.0.0/16"
}

variable "subnet1_address_space" {
  default = "10.1.0.0/24"
}

variable "subnet2_address_space" {
  default = "10.1.1.0/24"
}



#################################################
#     Providers
#################################################

provider "aws" {
  region = "us-east-1"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}


#################################################
#     DATA : PULL THE DATA FROM THE AWS
#################################################


data "aws_availability_zones" "available" {}



###########################################################
#    Resources
###########################################################

##################### NETWORKING ################

resource "aws_vpc" "vpc" {
  cidr_block = "${var.network_address_space}"
  enable_dns_hostnames = "true"
}


resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"
}


resource "aws_subnet" "subnet1" {
  cidr_block = "${var.subnet1_address_space}"
  vpc_id = "${aws_vpc.vpc.id}"
  map_public_ip_on_launch = "true"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
}


resource "aws_subnet" "subnet2" {
  cidr_block = "${var.subnet2_address_space}"
  vpc_id = "${aws_vpc.vpc.id}"
  map_public_ip_on_launch = "true"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
}


##################### ROUTING ################

resource "aws_route_table" "rtb" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }
}


resource "aws_route_table_association" "rta-subnet1" {
  route_table_id = "${aws_route_table.rtb.id}"
  subnet_id = "${aws_subnet.subnet1.id}"
}

resource "aws_route_table_association" "rta-subnet2" {
  route_table_id = "${aws_route_table.rtb.id}"
  subnet_id = "${aws_subnet.subnet2.id}"
}


###################### SECURITY GROUPS ##########################################

#################### Security Groups for loadbalancers ####################

resource "aws_security_group" "elb-sg" {
 name = "nginx-elb-sg"
 vpc_id = "${aws_vpc.vpc.id}"

  #ALLOW HTTP TRAFFIC
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
 #Allow all outbound
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}



##################### Nginx Security Group  for EC2 instances ################

resource "aws_security_group" "nginx-sg" {
  name = "nginx-sg"
  vpc_id = "${aws_vpc.vpc.id}"

  #SSH access from anywere
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
 #HTTP access from anywere
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["${var.network_address_space}"]
  }

  #outbound internet access
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


###################### CREATE LOADBALANCER #####################################



resource "aws_elb" "web" {
  name = "nginx-elb"
  subnets = ["${aws_subnet.subnet1.id}","${aws_subnet.subnet2.id}"]
  security_groups = ["${aws_security_group.elb-sg.id}"]
  instances = ["${aws_instance.nginx1.id}", "${aws_instance.nginx2.id}"]

  "listener" {
    instance_port = 80
    instance_protocol = "tcp"
    lb_port = 80
    lb_protocol = "tcp"
  }
}






resource "aws_instance" "nginx1" {
  ami = "ami-c58c1dd3"
  instance_type = "t2.micro"
  key_name = "${var.key_name}"
  subnet_id = "${aws_subnet.subnet1.id}"
  vpc_security_group_ids = ["${aws_security_group.nginx-sg.id}"]


  connection {
    user = "ec2-user"
    private_key = "${file(var.private_key_path)}"
  }


  provisioner "remote-exec" {

    inline = ["sudo yum install nginx -y", "sudo service nginx start", "echo '<html><h1>nginx1</h1></html>'|sudo tee  /usr/share/nginx/html/index.html"]
  }

}



resource "aws_instance" "nginx2" {
  ami = "ami-c58c1dd3"
  instance_type = "t2.micro"
  key_name = "${var.key_name}"
  subnet_id = "${aws_subnet.subnet2.id}"
  vpc_security_group_ids = ["${aws_security_group.nginx-sg.id}"]


  connection {
    user = "ec2-user"
    private_key = "${file(var.private_key_path)}"
  }


  provisioner "remote-exec" {

    inline = ["sudo yum install nginx -y", "sudo service nginx start", "echo '<html><h1>nginx2</h1></html>'|sudo tee  /usr/share/nginx/html/index.html"]
  }

}




#################################################
#    OUTPUT
#################################################

output "aws_elb_public_dns" {
  value = "${aws_elb.web.dns_name}"
}