
#TERRAFORM SCRIPT to run static website in S3 bucket 
provider "aws" {
    access_key = "${aws_access_key}"
    secret_key = "${aws_secret_key}"
    region = "${ap-south-1}"
}

resource "aws_s3_bucket" "mybucket" {
    bucket = "ym3240@srmist.edu.in"
    acl = "private"
    website {
        index_document = "index.html"
        error_document = "error.html"
    }
    tags = {
        Environment = "development"
        Name = "mytag"
    }
}

resource "aws_s3_bucket_object" "html" {
    for_each = fileset("path_of_static_website_files")

    bucket = aws_s3_bucket.mybucket.bucket
    key = each.value
    source = "defined_path_of_eachvalue"
    etag = filemd5(path_of_eachvalue)
    content_type = "text/html"
}

resource "aws_s3_bucket_object" "json" {
  for_each = fileset("json_file_path")

  bucket = aws_s3_bucket.mybucket.bucket
  key    = each.value
  source = "eachvalue_path"
  etag   = filemd5("eachvalue_path")
  content_type = "application/json"
}

locals {
  s3_origin_id = "ym3240@srmist.edu.in"
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "ym3240@srmist.edu.in"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
    origin {
        domain_name = aws_s3_bucket.mybucket.bucket_regional_domain_name
        origin_id = local.s3_origin_id

        s3_origin_config{
            origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.clodfront_access_identity_path

        }
    }

    enabled = true
    is_ipv6_enabled = true
    comment = "my_coudfront"
    default_root_object = "index.html"

    default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwaded_values {
        query_string = false

        cookies {
            forward = "none"
        }
    }
    }
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.b.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "mybucket" {
  bucket = aws_s3_bucket.mybucket.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

resource "aws_s3_bucket_public_access_block" "mybucket" {
  bucket = aws_s3_bucket.mybucket.id
}


#AWS CLI COMMANDS
#aws configure
#$ aws s3api create-bucket — bucket ym3240@srmist.edu.in — region ap-south-1 — create-bucket-configuration LocationConstraint=region
#$ aws s3 cp /root/name.JPG s3://ym3240@srmist.edu.in/ — acl public-read
# aws cloudfront create-distribution — origin-domain-name ym3240@srmist.edu.in.s3.ap-south-1.amazonaws.com — default-root-object name.JPG
#"Location”: “https://cloudfront.amazonaws.com/2023-07-28/distribution/idnumber"
#Image URL is: “idnumber.cloudfront.net”
