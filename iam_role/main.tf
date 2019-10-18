variable "name" {}
variable "policy" {}
variable "identifier" {}

# IAMロース
# 信頼ポリシーとロール名を定義
resource "aws_iam_role" "default" {
  name = var.name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# 信頼ポリシー
# IAMロールでの自身を何のサービスに関連付けるかの宣言
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = [var.identifier]
      type = "Service"
    }
  }
}

# IAMポリシー
# ポリシードキュメントを保持するリソース
# ポリシードキュメントは「実行可能なアクション」、「操作可能なリソース」を指定するJSON形式の記述
resource "aws_iam_policy" "default" {
  name = var.name
  policy = var.policy
}

# IAMロールにIAMポリシーをアタッチ
resource "aws_iam_role_policy_attachment" "default" {
  policy_arn = aws_iam_policy.default.arn
  role = aws_iam_role.default.name
}

output "iam_role_arn" {
  value = aws_iam_role.default.arn
}

output "iam_role_name" {
  value = aws_iam_role.default.name
}
