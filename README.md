# tf-sesm
create EC2 with AWS Sessions Manager profile.

## Components

- EC2
- IAM Role
- S3
  - Log store

## Usage

```
#########################
# Session Manager
#########################
module "sesm" {
  source = "git::https://git.dmm.com/nishioka-keiko/tf-sesm"

  name      = "service_name"
  subnet_id = "192.168.1.0/24"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| name | Resource name | string | n/a | yes |
| ami_id | AMI id | string |  "ami-0c3fd0f5d33134a76" | no |
| instance_type | Instance Type | string | "t2.micro" | no |
| subnet_id | Subnet id | string | n/a | yes |

## Outputs

Nothing
