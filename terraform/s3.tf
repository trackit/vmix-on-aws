# These S3 buckets will not be created unless var.create_bucket is set to true. And at least one value is set to the bucket_name variable

# Bucket used to archive media live files
resource "aws_s3_bucket" "media_live_bucket" {
  # count         = length(var.bucket_name)
  bucket        = var.media_live_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_acl" "media_live_bucket_acl" {
  bucket = aws_s3_bucket.media_live_bucket.id
  acl    = "private"
}

# Bucket used to output the converted video files from Media Convert
resource "aws_s3_bucket" "media_convert_bucket" {
  bucket        = var.media_convert_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_acl" "media_convert_bucket_acl" {
  bucket = aws_s3_bucket.media_convert_bucket.id
  acl    = "private"
}
