terraform {
  backend "s3" {
    bucket         = "rmt-tf-state" # change this
    key            = "prk/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}
