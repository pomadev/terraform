resource "aws_ecr_repository" "example" {
  name = "example"
}

// 「release」で始まるイマージタグを30個までに制限
resource "aws_ecr_lifecycle_policy" "example" {
  policy = <<EOF
  {
    "rules": [
      {
        "rulePriority": 1,
        "description": "Keep last 30 release tagged images",
        "selection": {
          "tagStatus": "tagged",
          "tagPrefixList": ["release"],
          "countType": "imageCountMoreThan",
          "countNumber": 30
      },
      "action": {
        "type": "expire"
      }
    }
  }
EOF
  repository = aws_ecr_repository.example.name
}
