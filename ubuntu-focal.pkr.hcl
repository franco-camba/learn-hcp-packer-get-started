packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "version" {
  type    = string
  default = "1.0.1"
}

data "amazon-ami" "ubuntu-focal-west-1" {
  region = "eu-west-1"
  filters = {
    name = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
  }
  most_recent = true
  owners      = ["099720109477"]
}

source "amazon-ebs" "basic-example-west-1" {
  region         = "eu-west-1"
  source_ami     = data.amazon-ami.ubuntu-focal-west-1.id
  instance_type  = "t2.small"
  ssh_username   = "ubuntu"
  ssh_agent_auth = false
  ami_name       = "packer_AWS_{{timestamp}}_v${var.version}"
}

data "amazon-ami" "ubuntu-focal-west-2" {
  region = "eu-west-2"
  filters = {
    name = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
  }
  most_recent = true
  owners      = ["099720109477"]
}

source "amazon-ebs" "basic-example-west-2" {
  region         = "eu-west-2"
  source_ami     = data.amazon-ami.ubuntu-focal-west-2.id
  instance_type  = "t2.small"
  ssh_username   = "ubuntu"
  ssh_agent_auth = false
  ami_name       = "packer_AWS_{{timestamp}}_v${var.version}"
}

build {
  hcp_packer_registry {
    bucket_name = "learn-packer-ubuntu"
    description = <<EOT
Some nice description about the image being published to HCP Packer Registry.
    EOT
    bucket_labels = {
      "owner"          = "platform-team"
      "os"             = "Ubuntu",
      "ubuntu-version" = "Focal 20.04",
    }

    build_labels = {
      "build-time"   = timestamp()
      "build-source" = basename(path.cwd)
    }
  }
  sources = [
    "source.amazon-ebs.basic-example-west-1",
    "source.amazon-ebs.basic-example-west-2"
  ]
}
