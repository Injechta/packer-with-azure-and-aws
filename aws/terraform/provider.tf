provider "aws" {
  profile = "simplon"
  region  = "eu-north-1"
  default_tags {
    tags = local.tags
  }
}
