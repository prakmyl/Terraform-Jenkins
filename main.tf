provider "aws" {
    region = "us-east-1"  # Set your desired AWS region
}

resource "aws_instance" "server" {
  ami                    = "ami-0261755bbcb8c4a84"
  instance_type          = "t2.micro"
 
  tags = {
    Name = "falsk-app"
  }
