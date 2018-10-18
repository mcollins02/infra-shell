provider "aws" {
  region = "us-east-1"

}

module "web_server_cluster" {
  source = "git::ssh://git@stash"

  cluster_name = "TBG"

  instance_type = "t2.micro"
  key_name = "terraform-key"
}
