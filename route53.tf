// 自動作成されたホストゾーンの参照
data "aws_route53_zone" "example" {
  name = "example.com"
}

// ホストゾーンの新規作成
resource "aws_route53_zone" "test_example" {
  name = "test.example.com"
}

// DNSレコードの定義
// 設定したドメインでALBへアクセスできるように
resource "aws_route53_record" "example" {
  name = data.aws_route53_zone.example.name
  type = "A"
  zone_id = data.aws_route53_zone.example.zone_id

  alias {
    evaluate_target_health = true
    name = aws_lb.example.dns_name
    zone_id = aws_lb.example.zone_id
  }
}

output "domain_name" {
  value = aws_route53_record.example.name
}

resource "aws_route53_record" "example_certificate" {
  name = aws_acm_certificate.example.domain_validation_options[0].resource_record_name
  type = aws_acm_certificate.example.domain_validation_options[0].resource_record_type
  records = [aws_acm_certificate.example.domain_validation_options[0].resource_record_value]
  zone_id = data.aws_route53_zone.example.id
  ttl = 60
}
