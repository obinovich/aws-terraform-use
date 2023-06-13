## cloudtrail-mgmnt ##                                                          # change variable
#### Create bucket ####
resource "aws_s3_bucket" "ref_ct_mgmnt_eu1" {                                # change variable
  bucket = "cloudtrail-mgmnt"                                             # change variable

  tags = {
    owner   = "secops"  
    product = "cloudtrail"                                                     # change variable
    service = "splunk"
  }

  provider = aws.region_eu                                              # change variable
}

#### Public ACL Ownership Config ####
resource "aws_s3_bucket_public_access_block" "ref_ct_mgmnt_eu1" {            # change variable
  bucket = aws_s3_bucket.ref_ct_mgmnt_eu1.bucket                             # change variable

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  provider = aws.region_eu                                              # change variable
}

resource "aws_s3_bucket_ownership_controls" "ref_ct_mgmnt_eu1" {             # change variable
  bucket = aws_s3_bucket.ref_ct_mgmnt_eu1.bucket                             # change variable
  rule {
    object_ownership = var.object_ownership_value_BOE
  }

  provider = aws.region_eu
}

#### Encryption Config ####
resource "aws_s3_bucket_server_side_encryption_configuration" "ref_ct_mgmnt_eu1" {       # change variable
  bucket = aws_s3_bucket.ref_ct_mgmnt_eu1.bucket                                         # change variable

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms-key_eu                                            # change variable
      sse_algorithm     = "aws:kms"
    }
  }

  provider = aws.region_eu
}

#### Data Lifecycle policy ####
resource "aws_s3_bucket_lifecycle_configuration" "ref_ct_mgmnt_eu1" {                    # change variable
  bucket = aws_s3_bucket.ref_ct_mgmnt_eu1.bucket                                         # change variable

  rule {
    id = "Move to Glacier after 30 days then delete after 367 days"

    status = "Enabled"

    transition {
      days          = 30
      storage_class = "GLACIER_IR"
    }

    expiration {
      days = 367
    }
  }

  provider = aws.region_eu
}

#### Create S3 event notification ####
resource "aws_s3_bucket_notification" "ref_ct_mgmnt_eu1" {
  bucket = aws_s3_bucket.ref_ct_mgmnt_eu1.bucket

  topic {
    id = "cloudtrail-logs-s3-event-notification"
    topic_arn     = aws_sns_topic.ref_bucket_services_cloudtrail_sns.arn
    events        = ["s3:ObjectCreated:Put"]
  }

  provider = aws.region_eu
}

#### Create Folder in S3 bucket ####
variable "ref_ct_mgmnt_eu1-s3_folder" {
  type = list
  description = "The list of S3 folders in cloudtrail-mgmnt"
  default  = [
    "subfolder1",
    "subfolder2"
    ]
}

#### Create Bucket ####
/* resource "aws_s3_object" "ref_ct_mgmnt_eu1" {
  bucket = aws_s3_bucket.ref_ct_mgmnt_eu1.bucket
  count   = "${length(var.ref_ct_mgmnt_eu1-s3_folder)}"
  key    = "${var.ref_ct_mgmnt_eu1-s3_folder[count.index]}/"

  provider = aws.region_eu
} */

#### Bucket Policy ####
resource "aws_s3_bucket_policy" "ref_ct_mgmnt_eu1" {
  bucket = aws_s3_bucket.ref_ct_mgmnt_eu1.bucket
  policy = data.aws_iam_policy_document.ref_ct_mgmnt_eu1.json
  
  provider = aws.region_eu
}

data "aws_iam_policy_document" "ref_ct_mgmnt_eu1" {
  statement {
    sid = "AWSCloudTrailAclCheck"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [ "cloudtrail.amazonaws.com" ]
      
    }
    actions = [ 
      "s3:GetBucketAcl",
    ]
    resources = [
      "${aws_s3_bucket.ref_ct_mgmnt_eu1.arn}",
    ]
    
  }

  statement {
    sid    = "AWSCloudTrailWrite-subfolder1"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions = [
      "s3:PutObject",
    ]
    resources = [
      "${aws_s3_bucket.ref_ct_mgmnt_eu1.arn}/AWSLogs/subfolder1/*",
    ]
    condition {
      test = "StringEquals"
      variable = "s3:x-amz-acl"
      values = [
        "bucket-owner-full-control"
      ]
    }
  }

  statement {
    sid    = "AWSCloudTrailWrite-subfolder2"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions = [
      "s3:PutObject",
    ]
    resources = [
      "${aws_s3_bucket.ref_ct_mgmnt_eu1.arn}/AWSLogs/subfolder2/*",
    ]
    condition {
      test = "StringEquals"
      variable = "s3:x-amz-acl"
      values = [
        "bucket-owner-full-control"
      ]
    }
  }
}
