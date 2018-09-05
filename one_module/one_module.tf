#################################################
#     Variables
#################################################

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}
variable "key_name" {
  default = "hanumankeys"
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
#    Resources
#################################################

resource "aws_instance" "nginx" {
  ami = "ami-c58c1dd3"
  instance_type = "t2.micro"
  key_name = "${var.key_name}"


  connection {
    user = "ec2-user"
    private_key = "${file(var.private_key_path)}"
  }


  provisioner "remote-exec" {

    inline = ["sudo yum install nginx -y", "sudo service nginx start"]
  }

}

#################################################
#    OUTPUT
#################################################


output "public_ip" {
  value = "${aws_instance.nginx.public_ip}"
}