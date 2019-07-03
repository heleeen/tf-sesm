#########################
# EC2
#########################
resource "aws_instance" "web" {
  ami                  = "${ var.ami_id }"
  instance_type        = "${ var.instance_type }"
  subnet_id            = "${ var.subnet_id }"
  iam_instance_profile = "${ aws_iam_instance_profile.sesm_profile.name }"

  tags = {
    Name = "${ var.name }-session-manager"
  }
}

#########################
# IAM Role
#########################
resource "aws_iam_instance_profile" "sesm_profile" {
  name = "${ var.name }-sesm-profile"
  role = "${ aws_iam_role.sesm.name }"
}

resource "aws_iam_role" "sesm" {
  name               = "${ var.name }-sesm"
  assume_role_policy = "${ data.aws_iam_policy_document.ec2_assume.json }"
}

data "aws_iam_policy_document" "ec2_assume" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = "${ aws_iam_role.sesm.name }"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

#########################
# Logs
#########################
resource "aws_ssm_document" "session_manager_settings" {
  name            = "SSM-SessionManagerRunShell"
  document_type   = "Session"
  document_format = "JSON"

  content = <<EOF
{
    "schemaVersion": "1.0",
    "description": "Document to hold regional settings for Session Manager",
    "sessionType": "Standard_Stream",
    "inputs": {
        "s3BucketName": "${ aws_s3_bucket.session_manager_log.id }",
        "s3EncryptionEnabled": true
    }
}
EOF
}

resource "aws_s3_bucket" "session_manager_log" {
  bucket = "${ var.name }-sesm-logs"

  lifecycle_rule {
    id                                     = "logs"
    enabled                                = true
    abort_incomplete_multipart_upload_days = 1

    expiration {
      days = 30
    }
  }
  
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
