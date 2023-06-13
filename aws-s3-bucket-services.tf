#######################################################
####### Event Shipping for Cloudtrail logs in S3 ########
#######################################################
#### Create deadletter Queue - cloudtrail ####
resource "aws_sqs_queue" "ref_bucket_services_cloudtrail_queue_dlq" {
  name                      = "cloudtrail-logs-s3-queue-dlq"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600
  receive_wait_time_seconds = 0
  visibility_timeout_seconds = 900
  sqs_managed_sse_enabled = false

  tags = {
    owner = "secops"
    purpose = "cloudtrail-logs-s3"
    product = "splunk"
  }

  provider = aws.region_eu
}

#### Create deadletter Queue policy - cloudtrail ####
resource "aws_sqs_queue_policy" "ref_bucket_services_cloudtrail_queue_dlq" {
  queue_url = aws_sqs_queue.ref_bucket_services_cloudtrail_queue_dlq.id
  policy    = data.aws_iam_policy_document.ref_bucket_services_cloudtrail_queue_dlq.json

  provider = aws.region_eu
}

data "aws_iam_policy_document" "ref_bucket_services_cloudtrail_queue_dlq" {
  statement {
    sid    = "__owner_statement"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::[awsAccoundId]:root"]
    }

    actions   = ["sqs:*"]
    resources = [aws_sqs_queue.ref_bucket_services_cloudtrail_queue_dlq.arn]
  }
}

#### Create Queue - cloudtrail ####
resource "aws_sqs_queue" "ref_bucket_services_cloudtrail_queue" {
  name                      = "cloudtrail-logs-s3-queue"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600
  receive_wait_time_seconds = 0
  visibility_timeout_seconds = 900
  sqs_managed_sse_enabled = false
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.ref_bucket_services_cloudtrail_queue_dlq.arn
    maxReceiveCount     = 10
  })

  tags = {
    owner = "secops"
    purpose = "cloudtrail-logs-s3"
    product = "splunk"
  }

  provider = aws.region_eu
}

#### Create Queue policy - cloudtrail ####
resource "aws_sqs_queue_policy" "ref_bucket_services_cloudtrail_queue" {
  queue_url = aws_sqs_queue.ref_bucket_services_cloudtrail_queue.id
  policy    = data.aws_iam_policy_document.ref_bucket_services_cloudtrail_queue.json

  provider = aws.region_eu
}

data "aws_iam_policy_document" "ref_bucket_services_cloudtrail_queue" {
  statement {
    sid    = "topic-subscription-cloudtrail-logs-in-s3"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.ref_bucket_services_cloudtrail_queue.arn]
    condition {
      test = "ArnLike"
      variable = "aws:SourceArn"
      values = [aws_sns_topic.ref_bucket_services_cloudtrail_sns.arn]
    }
  }
}


#### Create sns topic - cloudtrail ####
resource "aws_sns_topic" "ref_bucket_services_cloudtrail_sns" {
  name = "cloudtrail-logs-s3-notification-topic"

  provider = aws.region_eu
}

#### Create sns topic policy - cloudtrail ####
resource "aws_sns_topic_policy" "ref_bucket_services_cloudtrail_sns" {
  arn = aws_sns_topic.ref_bucket_services_cloudtrail_sns.arn
  policy = data.aws_iam_policy_document.ref_bucket_services_cloudtrail_sns.json

  provider = aws.region_eu
}

data "aws_iam_policy_document" "ref_bucket_services_cloudtrail_sns" {
  policy_id = "__default_policy_ID"

  statement {
    sid = "AWSCloudTrail_in_S3_SNSPolicy20230505"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [ "s3.amazonaws.com" ]
      
    }
    actions = [ 
      "SNS:Publish"
    ]
    resources = [aws_sns_topic.ref_bucket_services_cloudtrail_sns.arn]
  }
}

#### Create sns topic subscription - cloudtrail ####
resource "aws_sns_topic_subscription" "ref_bucket_services_cloudtrail_sqs_target" {
  topic_arn = aws_sns_topic.ref_bucket_services_cloudtrail_sns.arn
  protocol  = "sqs"
  endpoint = aws_sqs_queue.ref_bucket_services_cloudtrail_queue.arn

  provider = aws.region_eu
}


#######################################################
####### Event Shipping for VPC Flow logs in S3 ########
#######################################################
#### Create deadletter Queue - vpc ####
resource "aws_sqs_queue" "ref_bucket_services_vpc_queue_dlq" {
  name                      = "vpcflow-logs-s3-queue-dlq"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600
  receive_wait_time_seconds = 0
  visibility_timeout_seconds = 900
  sqs_managed_sse_enabled = false

  tags = {
    owner = "secops"
    purpose = "vpcflow-logs-s3"
    product = "splunk"
  }

  provider = aws.region_eu
}

#### Create deadletter Queue policy - vpc ####
resource "aws_sqs_queue_policy" "ref_bucket_services_vpc_queue_dlq" {
  queue_url = aws_sqs_queue.ref_bucket_services_vpc_queue_dlq.id
  policy    = data.aws_iam_policy_document.ref_bucket_services_vpc_queue_dlq.json

  provider = aws.region_eu
}

data "aws_iam_policy_document" "ref_bucket_services_vpc_queue_dlq" {
  statement {
    sid    = "__owner_statement"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::[awsAccoundId]:root"]
    }

    actions   = ["sqs:*"]
    resources = [aws_sqs_queue.ref_bucket_services_vpc_queue_dlq.arn]
  }
}

#### Create Queue - vpc ####
resource "aws_sqs_queue" "ref_bucket_services_vpc_queue" {
  name                      = "vpcflow-logs-s3-queue"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600
  receive_wait_time_seconds = 0
  visibility_timeout_seconds = 900
  sqs_managed_sse_enabled = false
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.ref_bucket_services_vpc_queue_dlq.arn
    maxReceiveCount     = 10
  })

  tags = {
    owner = "secops"
    purpose = "vpcflow-logs-s3"
    product = "splunk"
  }

  provider = aws.region_eu
}

#### Create Queue policy - vpc ####
resource "aws_sqs_queue_policy" "ref_bucket_services_vpc_queue" {
  queue_url = aws_sqs_queue.ref_bucket_services_vpc_queue.id
  policy    = data.aws_iam_policy_document.ref_bucket_services_vpc_queue.json

  provider = aws.region_eu
}

data "aws_iam_policy_document" "ref_bucket_services_vpc_queue" {
  statement {
    sid    = "topic-subscription-vpcflow-logs-in-s3"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.ref_bucket_services_vpc_queue.arn]
    condition {
      test = "ArnLike"
      variable = "aws:SourceArn"
      values = [aws_sns_topic.ref_bucket_services_vpc_sns.arn]
    }
  }
}


#### Create sns topic - vpc ####
resource "aws_sns_topic" "ref_bucket_services_vpc_sns" {
  name = "vpcflow-logs-s3-notification-topic"

  provider = aws.region_eu
}

#### Create sns topic policy - vpc ####
resource "aws_sns_topic_policy" "ref_bucket_services_vpc_sns" {
  arn = aws_sns_topic.ref_bucket_services_vpc_sns.arn
  policy = data.aws_iam_policy_document.ref_bucket_services_vpc_sns.json

  provider = aws.region_eu
}

data "aws_iam_policy_document" "ref_bucket_services_vpc_sns" {
  policy_id = "__default_policy_ID"

  statement {
    sid = "AWSVPCFlow_in_S3_SNSPolicy20230601"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [ "s3.amazonaws.com" ]
      
    }
    actions = [ 
      "SNS:Publish"
    ]
    resources = [aws_sns_topic.ref_bucket_services_vpc_sns.arn]
  }
}

#### Create sns topic subscription - vpc ####
resource "aws_sns_topic_subscription" "ref_bucket_services_vpc_sqs_target" {
  topic_arn = aws_sns_topic.ref_bucket_services_vpc_sns.arn
  protocol  = "sqs"
  endpoint = aws_sqs_queue.ref_bucket_services_vpc_queue.arn

  provider = aws.region_eu
}

###############################################################
####### Event Shipping for Cloudflare-CP-EU logs in S3 ########
###############################################################
#### Create deadletter Queue - cloudflare-cp-eu ####
resource "aws_sqs_queue" "ref_bucket_services_cloudflare_cp_eu_queue_dlq" {
  name                      = "cloudflare-cp-eu-logs-s3-queue-dlq"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600
  receive_wait_time_seconds = 0
  visibility_timeout_seconds = 900
  sqs_managed_sse_enabled = false

  tags = {
    owner = "secops"
    purpose = "cloudflare-cp-eu-logs-s3"
    product = "splunk"
  }

  provider = aws.region_eu
}

#### Create deadletter Queue policy - cloudflare-cp-eu ####
resource "aws_sqs_queue_policy" "ref_bucket_services_cloudflare_cp_eu_queue_dlq" {
  queue_url = aws_sqs_queue.ref_bucket_services_cloudflare_cp_eu_queue_dlq.id
  policy    = data.aws_iam_policy_document.ref_bucket_services_cloudflare_cp_eu_queue_dlq.json

  provider = aws.region_eu
}

data "aws_iam_policy_document" "ref_bucket_services_cloudflare_cp_eu_queue_dlq" {
  statement {
    sid    = "__owner_statement"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::[awsAccoundId]:root"]
    }

    actions   = ["sqs:*"]
    resources = [aws_sqs_queue.ref_bucket_services_cloudflare_cp_eu_queue_dlq.arn]
  }
}

#### Create Queue - cloudflare-cp-eu ####
resource "aws_sqs_queue" "ref_bucket_services_cloudflare_cp_eu_queue" {
  name                      = "cloudflare-cp-eu-logs-s3-queue"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600
  receive_wait_time_seconds = 0
  visibility_timeout_seconds = 900
  sqs_managed_sse_enabled = false
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.ref_bucket_services_cloudflare_cp_eu_queue_dlq.arn
    maxReceiveCount     = 10
  })

  tags = {
    owner = "secops"
    purpose = "cloudflare-cp-eu-logs-s3"
    product = "splunk"
  }

  provider = aws.region_eu
}

#### Create Queue policy - cloudflare-cp-eu ####
resource "aws_sqs_queue_policy" "ref_bucket_services_cloudflare_cp_eu_queue" {
  queue_url = aws_sqs_queue.ref_bucket_services_cloudflare_cp_eu_queue.id
  policy    = data.aws_iam_policy_document.ref_bucket_services_cloudflare_cp_eu_queue.json

  provider = aws.region_eu
}

data "aws_iam_policy_document" "ref_bucket_services_cloudflare_cp_eu_queue" {
  statement {
    sid    = "topic-subscription-cloudflare-cp-eu-logs-in-s3"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.ref_bucket_services_cloudflare_cp_eu_queue.arn]
    condition {
      test = "ArnLike"
      variable = "aws:SourceArn"
      values = [aws_sns_topic.ref_bucket_services_cloudflare_cp_eu_sns.arn]
    }
  }
}


#### Create sns topic - cloudflare-cp-eu ####
resource "aws_sns_topic" "ref_bucket_services_cloudflare_cp_eu_sns" {
  name = "cloudflare-cp-eu-logs-s3-notification-topic"

  provider = aws.region_eu
}

#### Create sns topic policy - cloudflare-cp-eu ####
resource "aws_sns_topic_policy" "ref_bucket_services_cloudflare_cp_eu_sns" {
  arn = aws_sns_topic.ref_bucket_services_cloudflare_cp_eu_sns.arn
  policy = data.aws_iam_policy_document.ref_bucket_services_cloudflare_cp_eu_sns.json

  provider = aws.region_eu
}

data "aws_iam_policy_document" "ref_bucket_services_cloudflare_cp_eu_sns" {
  policy_id = "__default_policy_ID"

  statement {
    sid = "cloudflare_cp_eu_in_S3_SNSPolicy20230605"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [ "s3.amazonaws.com" ]
      
    }
    actions = [ 
      "SNS:Publish"
    ]
    resources = [aws_sns_topic.ref_bucket_services_cloudflare_cp_eu_sns.arn]
  }
}

#### Create sns topic subscription - cloudflare-cp-eu ####
resource "aws_sns_topic_subscription" "ref_bucket_services_cloudflare_cp_eu_sqs_target" {
  topic_arn = aws_sns_topic.ref_bucket_services_cloudflare_cp_eu_sns.arn
  protocol  = "sqs"
  endpoint = aws_sqs_queue.ref_bucket_services_cloudflare_cp_eu_queue.arn

  provider = aws.region_eu
}


###############################################################
####### Event Shipping for cloudflare-oss-eu logs in S3 ########
###############################################################
#### Create deadletter Queue - cloudflare-oss-eu ####
resource "aws_sqs_queue" "ref_bucket_services_cloudflare_oss_eu_queue_dlq" {
  name                      = "cloudflare-oss-eu-logs-s3-queue-dlq"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600
  receive_wait_time_seconds = 0
  visibility_timeout_seconds = 900
  sqs_managed_sse_enabled = false

  tags = {
    owner = "secops"
    purpose = "cloudflare-oss-eu-logs-s3"
    product = "splunk"
  }

  provider = aws.region_eu
}

#### Create deadletter Queue policy - cloudflare-oss-eu ####
resource "aws_sqs_queue_policy" "ref_bucket_services_cloudflare_oss_eu_queue_dlq" {
  queue_url = aws_sqs_queue.ref_bucket_services_cloudflare_oss_eu_queue_dlq.id
  policy    = data.aws_iam_policy_document.ref_bucket_services_cloudflare_oss_eu_queue_dlq.json

  provider = aws.region_eu
}

data "aws_iam_policy_document" "ref_bucket_services_cloudflare_oss_eu_queue_dlq" {
  statement {
    sid    = "__owner_statement"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::[awsAccoundId]:root"]
    }

    actions   = ["sqs:*"]
    resources = [aws_sqs_queue.ref_bucket_services_cloudflare_oss_eu_queue_dlq.arn]
  }
}

#### Create Queue - cloudflare-oss-eu ####
resource "aws_sqs_queue" "ref_bucket_services_cloudflare_oss_eu_queue" {
  name                      = "cloudflare-oss-eu-logs-s3-queue"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600
  receive_wait_time_seconds = 0
  visibility_timeout_seconds = 900
  sqs_managed_sse_enabled = false
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.ref_bucket_services_cloudflare_oss_eu_queue_dlq.arn
    maxReceiveCount     = 10
  })

  tags = {
    owner = "secops"
    purpose = "cloudflare-oss-eu-logs-s3"
    product = "splunk"
  }

  provider = aws.region_eu
}

#### Create Queue policy - cloudflare-oss-eu ####
resource "aws_sqs_queue_policy" "ref_bucket_services_cloudflare_oss_eu_queue" {
  queue_url = aws_sqs_queue.ref_bucket_services_cloudflare_oss_eu_queue.id
  policy    = data.aws_iam_policy_document.ref_bucket_services_cloudflare_oss_eu_queue.json

  provider = aws.region_eu
}

data "aws_iam_policy_document" "ref_bucket_services_cloudflare_oss_eu_queue" {
  statement {
    sid    = "topic-subscription-cloudflare-oss-eu-logs-in-s3"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.ref_bucket_services_cloudflare_oss_eu_queue.arn]
    condition {
      test = "ArnLike"
      variable = "aws:SourceArn"
      values = [aws_sns_topic.ref_bucket_services_cloudflare_oss_eu_sns.arn]
    }
  }
}


#### Create sns topic - cloudflare-oss-eu ####
resource "aws_sns_topic" "ref_bucket_services_cloudflare_oss_eu_sns" {
  name = "cloudflare-oss-eu-logs-s3-notification-topic"

  provider = aws.region_eu
}

#### Create sns topic policy - cloudflare-oss-eu ####
resource "aws_sns_topic_policy" "ref_bucket_services_cloudflare_oss_eu_sns" {
  arn = aws_sns_topic.ref_bucket_services_cloudflare_oss_eu_sns.arn
  policy = data.aws_iam_policy_document.ref_bucket_services_cloudflare_oss_eu_sns.json

  provider = aws.region_eu
}

data "aws_iam_policy_document" "ref_bucket_services_cloudflare_oss_eu_sns" {
  policy_id = "__default_policy_ID"

  statement {
    sid = "cloudflare_oss_eu_in_S3_SNSPolicy20230605"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [ "s3.amazonaws.com" ]
      
    }
    actions = [ 
      "SNS:Publish"
    ]
    resources = [aws_sns_topic.ref_bucket_services_cloudflare_oss_eu_sns.arn]
  }
}

#### Create sns topic subscription - cloudflare-oss-eu ####
resource "aws_sns_topic_subscription" "ref_bucket_services_cloudflare_oss_eu_sqs_target" {
  topic_arn = aws_sns_topic.ref_bucket_services_cloudflare_oss_eu_sns.arn
  protocol  = "sqs"
  endpoint = aws_sqs_queue.ref_bucket_services_cloudflare_oss_eu_queue.arn

  provider = aws.region_eu
}

###############################################################
####### Event Shipping for cloudflare-tid-eu logs in S3 ########
###############################################################
#### Create deadletter Queue - cloudflare-tid-eu ####
resource "aws_sqs_queue" "ref_bucket_services_cloudflare_tid_eu_queue_dlq" {
  name                      = "cloudflare-tid-eu-logs-s3-queue-dlq"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600
  receive_wait_time_seconds = 0
  visibility_timeout_seconds = 900
  sqs_managed_sse_enabled = false

  tags = {
    owner = "secops"
    purpose = "cloudflare-tid-eu-logs-s3"
    product = "splunk"
  }

  provider = aws.region_eu
}

#### Create deadletter Queue policy - cloudflare-tid-eu ####
resource "aws_sqs_queue_policy" "ref_bucket_services_cloudflare_tid_eu_queue_dlq" {
  queue_url = aws_sqs_queue.ref_bucket_services_cloudflare_tid_eu_queue_dlq.id
  policy    = data.aws_iam_policy_document.ref_bucket_services_cloudflare_tid_eu_queue_dlq.json

  provider = aws.region_eu
}

data "aws_iam_policy_document" "ref_bucket_services_cloudflare_tid_eu_queue_dlq" {
  statement {
    sid    = "__owner_statement"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::[awsAccoundId]:root"]
    }

    actions   = ["sqs:*"]
    resources = [aws_sqs_queue.ref_bucket_services_cloudflare_tid_eu_queue_dlq.arn]
  }
}

#### Create Queue - cloudflare-tid-eu ####
resource "aws_sqs_queue" "ref_bucket_services_cloudflare_tid_eu_queue" {
  name                      = "cloudflare-tid-eu-logs-s3-queue"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600
  receive_wait_time_seconds = 0
  visibility_timeout_seconds = 900
  sqs_managed_sse_enabled = false
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.ref_bucket_services_cloudflare_tid_eu_queue_dlq.arn
    maxReceiveCount     = 10
  })

  tags = {
    owner = "secops"
    purpose = "cloudflare-tid-eu-logs-s3"
    product = "splunk"
  }

  provider = aws.region_eu
}

#### Create Queue policy - cloudflare-tid-eu ####
resource "aws_sqs_queue_policy" "ref_bucket_services_cloudflare_tid_eu_queue" {
  queue_url = aws_sqs_queue.ref_bucket_services_cloudflare_tid_eu_queue.id
  policy    = data.aws_iam_policy_document.ref_bucket_services_cloudflare_tid_eu_queue.json

  provider = aws.region_eu
}

data "aws_iam_policy_document" "ref_bucket_services_cloudflare_tid_eu_queue" {
  statement {
    sid    = "topic-subscription-cloudflare-tid-eu-logs-in-s3"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.ref_bucket_services_cloudflare_tid_eu_queue.arn]
    condition {
      test = "ArnLike"
      variable = "aws:SourceArn"
      values = [aws_sns_topic.ref_bucket_services_cloudflare_tid_eu_sns.arn]
    }
  }
}


#### Create sns topic - cloudflare-tid-eu ####
resource "aws_sns_topic" "ref_bucket_services_cloudflare_tid_eu_sns" {
  name = "cloudflare-tid-eu-logs-s3-notification-topic"

  provider = aws.region_eu
}

#### Create sns topic policy - cloudflare-tid-eu ####
resource "aws_sns_topic_policy" "ref_bucket_services_cloudflare_tid_eu_sns" {
  arn = aws_sns_topic.ref_bucket_services_cloudflare_tid_eu_sns.arn
  policy = data.aws_iam_policy_document.ref_bucket_services_cloudflare_tid_eu_sns.json

  provider = aws.region_eu
}

data "aws_iam_policy_document" "ref_bucket_services_cloudflare_tid_eu_sns" {
  policy_id = "__default_policy_ID"

  statement {
    sid = "cloudflare_tid_eu_in_S3_SNSPolicy20230605"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [ "s3.amazonaws.com" ]
      
    }
    actions = [ 
      "SNS:Publish"
    ]
    resources = [aws_sns_topic.ref_bucket_services_cloudflare_tid_eu_sns.arn]
  }
}

#### Create sns topic subscription - cloudflare-tid-eu ####
resource "aws_sns_topic_subscription" "ref_bucket_services_cloudflare_tid_eu_sqs_target" {
  topic_arn = aws_sns_topic.ref_bucket_services_cloudflare_tid_eu_sns.arn
  protocol  = "sqs"
  endpoint = aws_sqs_queue.ref_bucket_services_cloudflare_tid_eu_queue.arn

  provider = aws.region_eu
}


###############################################################
####### Event Shipping for cloudflare-oss-au logs in S3 ########
###############################################################
#### Create deadletter Queue - cloudflare-oss-au ####
resource "aws_sqs_queue" "ref_bucket_services_cloudflare_oss_au_queue_dlq" {
  name                      = "cloudflare-oss-au-logs-s3-queue-dlq"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600
  receive_wait_time_seconds = 0
  visibility_timeout_seconds = 900
  sqs_managed_sse_enabled = false

  tags = {
    owner = "secops"
    purpose = "cloudflare-oss-au-logs-s3"
    product = "splunk"
  }

  provider = aws.region_ap
}

#### Create deadletter Queue policy - cloudflare-oss-au ####
resource "aws_sqs_queue_policy" "ref_bucket_services_cloudflare_oss_au_queue_dlq" {
  queue_url = aws_sqs_queue.ref_bucket_services_cloudflare_oss_au_queue_dlq.id
  policy    = data.aws_iam_policy_document.ref_bucket_services_cloudflare_oss_au_queue_dlq.json

  provider = aws.region_ap
}

data "aws_iam_policy_document" "ref_bucket_services_cloudflare_oss_au_queue_dlq" {
  statement {
    sid    = "__owner_statement"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::[awsAccoundId]:root"]
    }

    actions   = ["sqs:*"]
    resources = [aws_sqs_queue.ref_bucket_services_cloudflare_oss_au_queue_dlq.arn]
  }
}

#### Create Queue - cloudflare-oss-au ####
resource "aws_sqs_queue" "ref_bucket_services_cloudflare_oss_au_queue" {
  name                      = "cloudflare-oss-au-logs-s3-queue"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600
  receive_wait_time_seconds = 0
  visibility_timeout_seconds = 900
  sqs_managed_sse_enabled = false
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.ref_bucket_services_cloudflare_oss_au_queue_dlq.arn
    maxReceiveCount     = 10
  })

  tags = {
    owner = "secops"
    purpose = "cloudflare-oss-au-logs-s3"
    product = "splunk"
  }

  provider = aws.region_ap
}

#### Create Queue policy - cloudflare-oss-au ####
resource "aws_sqs_queue_policy" "ref_bucket_services_cloudflare_oss_au_queue" {
  queue_url = aws_sqs_queue.ref_bucket_services_cloudflare_oss_au_queue.id
  policy    = data.aws_iam_policy_document.ref_bucket_services_cloudflare_oss_au_queue.json

  provider = aws.region_ap
}

data "aws_iam_policy_document" "ref_bucket_services_cloudflare_oss_au_queue" {
  statement {
    sid    = "topic-subscription-cloudflare-oss-au-logs-in-s3"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.ref_bucket_services_cloudflare_oss_au_queue.arn]
    condition {
      test = "ArnLike"
      variable = "aws:SourceArn"
      values = [aws_sns_topic.ref_bucket_services_cloudflare_oss_au_sns.arn]
    }
  }
}


#### Create sns topic - cloudflare-oss-au ####
resource "aws_sns_topic" "ref_bucket_services_cloudflare_oss_au_sns" {
  name = "cloudflare-oss-au-logs-s3-notification-topic"

  provider = aws.region_ap
}

#### Create sns topic policy - cloudflare-oss-au ####
resource "aws_sns_topic_policy" "ref_bucket_services_cloudflare_oss_au_sns" {
  arn = aws_sns_topic.ref_bucket_services_cloudflare_oss_au_sns.arn
  policy = data.aws_iam_policy_document.ref_bucket_services_cloudflare_oss_au_sns.json

  provider = aws.region_ap
}

data "aws_iam_policy_document" "ref_bucket_services_cloudflare_oss_au_sns" {
  policy_id = "__default_policy_ID"

  statement {
    sid = "cloudflare_oss_au_in_S3_SNSPolicy20230605"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [ "s3.amazonaws.com" ]
      
    }
    actions = [ 
      "SNS:Publish"
    ]
    resources = [aws_sns_topic.ref_bucket_services_cloudflare_oss_au_sns.arn]
  }
}

#### Create sns topic subscription - cloudflare-oss-au ####
resource "aws_sns_topic_subscription" "ref_bucket_services_cloudflare_oss_au_sqs_target" {
  topic_arn = aws_sns_topic.ref_bucket_services_cloudflare_oss_au_sns.arn
  protocol  = "sqs"
  endpoint = aws_sqs_queue.ref_bucket_services_cloudflare_oss_au_queue.arn

  provider = aws.region_ap
}


###############################################################
####### Event Shipping for cloudflare-oss-ca logs in S3 ########
###############################################################
#### Create deadletter Queue - cloudflare-oss-ca ####
resource "aws_sqs_queue" "ref_bucket_services_cloudflare_oss_ca_queue_dlq" {
  name                      = "cloudflare-oss-ca-logs-s3-queue-dlq"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600
  receive_wait_time_seconds = 0
  visibility_timeout_seconds = 900
  sqs_managed_sse_enabled = false

  tags = {
    owner = "secops"
    purpose = "cloudflare-oss-ca-logs-s3"
    product = "splunk"
  }

  provider = aws.region_ca
}

#### Create deadletter Queue policy - cloudflare-oss-ca ####
resource "aws_sqs_queue_policy" "ref_bucket_services_cloudflare_oss_ca_queue_dlq" {
  queue_url = aws_sqs_queue.ref_bucket_services_cloudflare_oss_ca_queue_dlq.id
  policy    = data.aws_iam_policy_document.ref_bucket_services_cloudflare_oss_ca_queue_dlq.json

  provider = aws.region_ca
}

data "aws_iam_policy_document" "ref_bucket_services_cloudflare_oss_ca_queue_dlq" {
  statement {
    sid    = "__owner_statement"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::[awsAccoundId]:root"]
    }

    actions   = ["sqs:*"]
    resources = [aws_sqs_queue.ref_bucket_services_cloudflare_oss_ca_queue_dlq.arn]
  }
}

#### Create Queue - cloudflare-oss-ca ####
resource "aws_sqs_queue" "ref_bucket_services_cloudflare_oss_ca_queue" {
  name                      = "cloudflare-oss-ca-logs-s3-queue"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600
  receive_wait_time_seconds = 0
  visibility_timeout_seconds = 900
  sqs_managed_sse_enabled = false
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.ref_bucket_services_cloudflare_oss_ca_queue_dlq.arn
    maxReceiveCount     = 10
  })

  tags = {
    owner = "secops"
    purpose = "cloudflare-oss-ca-logs-s3"
    product = "splunk"
  }

  provider = aws.region_ca
}

#### Create Queue policy - cloudflare-oss-ca ####
resource "aws_sqs_queue_policy" "ref_bucket_services_cloudflare_oss_ca_queue" {
  queue_url = aws_sqs_queue.ref_bucket_services_cloudflare_oss_ca_queue.id
  policy    = data.aws_iam_policy_document.ref_bucket_services_cloudflare_oss_ca_queue.json

  provider = aws.region_ca
}

data "aws_iam_policy_document" "ref_bucket_services_cloudflare_oss_ca_queue" {
  statement {
    sid    = "topic-subscription-cloudflare-oss-ca-logs-in-s3"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.ref_bucket_services_cloudflare_oss_ca_queue.arn]
    condition {
      test = "ArnLike"
      variable = "aws:SourceArn"
      values = [aws_sns_topic.ref_bucket_services_cloudflare_oss_ca_sns.arn]
    }
  }
}


#### Create sns topic - cloudflare-oss-ca ####
resource "aws_sns_topic" "ref_bucket_services_cloudflare_oss_ca_sns" {
  name = "cloudflare-oss-ca-logs-s3-notification-topic"

  provider = aws.region_ca
}

#### Create sns topic policy - cloudflare-oss-ca ####
resource "aws_sns_topic_policy" "ref_bucket_services_cloudflare_oss_ca_sns" {
  arn = aws_sns_topic.ref_bucket_services_cloudflare_oss_ca_sns.arn
  policy = data.aws_iam_policy_document.ref_bucket_services_cloudflare_oss_ca_sns.json

  provider = aws.region_ca
}

data "aws_iam_policy_document" "ref_bucket_services_cloudflare_oss_ca_sns" {
  policy_id = "__default_policy_ID"

  statement {
    sid = "cloudflare_oss_ca_in_S3_SNSPolicy20230605"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [ "s3.amazonaws.com" ]
      
    }
    actions = [ 
      "SNS:Publish"
    ]
    resources = [aws_sns_topic.ref_bucket_services_cloudflare_oss_ca_sns.arn]
  }
}

#### Create sns topic subscription - cloudflare-oss-ca ####
resource "aws_sns_topic_subscription" "ref_bucket_services_cloudflare_oss_ca_sqs_target" {
  topic_arn = aws_sns_topic.ref_bucket_services_cloudflare_oss_ca_sns.arn
  protocol  = "sqs"
  endpoint = aws_sqs_queue.ref_bucket_services_cloudflare_oss_ca_queue.arn

  provider = aws.region_ca
}


###############################################################
####### Event Shipping for cloudflare-oss-us logs in S3 ########
###############################################################
#### Create deadletter Queue - cloudflare-oss-us ####
resource "aws_sqs_queue" "ref_bucket_services_cloudflare_oss_us_queue_dlq" {
  name                      = "cloudflare-oss-us-logs-s3-queue-dlq"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600
  receive_wait_time_seconds = 0
  visibility_timeout_seconds = 900
  sqs_managed_sse_enabled = false

  tags = {
    owner = "secops"
    purpose = "cloudflare-oss-us-logs-s3"
    product = "splunk"
  }

  provider = aws.region_us
}

#### Create deadletter Queue policy - cloudflare-oss-us ####
resource "aws_sqs_queue_policy" "ref_bucket_services_cloudflare_oss_us_queue_dlq" {
  queue_url = aws_sqs_queue.ref_bucket_services_cloudflare_oss_us_queue_dlq.id
  policy    = data.aws_iam_policy_document.ref_bucket_services_cloudflare_oss_us_queue_dlq.json

  provider = aws.region_us
}

data "aws_iam_policy_document" "ref_bucket_services_cloudflare_oss_us_queue_dlq" {
  statement {
    sid    = "__owner_statement"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::[awsAccoundId]:root"]
    }

    actions   = ["sqs:*"]
    resources = [aws_sqs_queue.ref_bucket_services_cloudflare_oss_us_queue_dlq.arn]
  }
}

#### Create Queue - cloudflare-oss-us ####
resource "aws_sqs_queue" "ref_bucket_services_cloudflare_oss_us_queue" {
  name                      = "cloudflare-oss-us-logs-s3-queue"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600
  receive_wait_time_seconds = 0
  visibility_timeout_seconds = 900
  sqs_managed_sse_enabled = false
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.ref_bucket_services_cloudflare_oss_us_queue_dlq.arn
    maxReceiveCount     = 10
  })

  tags = {
    owner = "secops"
    purpose = "cloudflare-oss-us-logs-s3"
    product = "splunk"
  }

  provider = aws.region_us
}

#### Create Queue policy - cloudflare-oss-us ####
resource "aws_sqs_queue_policy" "ref_bucket_services_cloudflare_oss_us_queue" {
  queue_url = aws_sqs_queue.ref_bucket_services_cloudflare_oss_us_queue.id
  policy    = data.aws_iam_policy_document.ref_bucket_services_cloudflare_oss_us_queue.json

  provider = aws.region_us
}

data "aws_iam_policy_document" "ref_bucket_services_cloudflare_oss_us_queue" {
  statement {
    sid    = "topic-subscription-cloudflare-oss-us-logs-in-s3"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.ref_bucket_services_cloudflare_oss_us_queue.arn]
    condition {
      test = "ArnLike"
      variable = "aws:SourceArn"
      values = [aws_sns_topic.ref_bucket_services_cloudflare_oss_us_sns.arn]
    }
  }
}


#### Create sns topic - cloudflare-oss-us ####
resource "aws_sns_topic" "ref_bucket_services_cloudflare_oss_us_sns" {
  name = "cloudflare-oss-us-logs-s3-notification-topic"

  provider = aws.region_us
}

#### Create sns topic policy - cloudflare-oss-us ####
resource "aws_sns_topic_policy" "ref_bucket_services_cloudflare_oss_us_sns" {
  arn = aws_sns_topic.ref_bucket_services_cloudflare_oss_us_sns.arn
  policy = data.aws_iam_policy_document.ref_bucket_services_cloudflare_oss_us_sns.json

  provider = aws.region_us
}

data "aws_iam_policy_document" "ref_bucket_services_cloudflare_oss_us_sns" {
  policy_id = "__default_policy_ID"

  statement {
    sid = "cloudflare_oss_us_in_S3_SNSPolicy20230605"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [ "s3.amazonaws.com" ]
      
    }
    actions = [ 
      "SNS:Publish"
    ]
    resources = [aws_sns_topic.ref_bucket_services_cloudflare_oss_us_sns.arn]
  }
}

#### Create sns topic subscription - cloudflare-oss-us ####
resource "aws_sns_topic_subscription" "ref_bucket_services_cloudflare_oss_us_sqs_target" {
  topic_arn = aws_sns_topic.ref_bucket_services_cloudflare_oss_us_sns.arn
  protocol  = "sqs"
  endpoint = aws_sqs_queue.ref_bucket_services_cloudflare_oss_us_queue.arn

  provider = aws.region_us
}
