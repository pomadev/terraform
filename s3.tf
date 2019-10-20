// プライベートバケット
resource "aws_s3_bucket" "private" {
  // バケット名 - 全世界で一意にする必要あり
  bucket = "private-pragmatic-terraform"

  // バージョニング
  // 有効にすると、オブジェクトを変更・削除しても、いつでも以前のバージョンへ復元可能
  versioning {
    enabled = true
  }

  // 暗号化
  // オブジェクト保存時に自動で暗号化、オブジェクト参照時に自動で復号
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

// ブロックパブリックアクセス
// 予期しないオブジェクトの公開を抑止
resource "aws_s3_bucket_public_access_block" "private" {
  bucket = "aws_s3_bucket.private.id"
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

// パブリックバケット
resource "aws_s3_bucket" "public" {
  bucket = "public-pragmatic-terraform"
  acl = "public-read"

  cors_rule {
    allowed_origins = ["https://example.com"]
    allowed_methods = ["GET"]
    allowed_headers = ["*"]
    max_age_seconds = 3000
  }
}

// ログバケット
resource "aws_s3_bucket" "alb_log" {
  bucket = "alb-log-pragmatic-terraform"

  lifecycle_rule {
    enabled = true

    // 180日経過したファイルを自動的に削除
    expiration {
      days = "180"
    }
  }
}

// バケットポリシー
// S3バケットへのアクセス権を設定
resource "aws_s3_bucket_policy" "alb_log" {
  bucket = "aws_s3_bucket.alb_log.id"
  policy = data.aws_iam_policy_document.alb_log.json
}

data "aws_iam_policy_document" "alb_log" {
  statement {
    effect = "Allow"
    actions = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.alb_log.id}/*"]

    // ALBの場合は、AWSが管理しているアカウントから書き込みを行う
    principals {
      identifiers = ["582318560864"] // 書き込みを行うアカウントID(リージョンごとに異なる)
      type = "AWS"
    }
  }
}
