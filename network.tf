// VPCは、他のネットワークから論理的に切り離されている仮想ネットワーク
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "example"
  }
}

resource "aws_subnet" "public" {
  vpc_id  = aws_vpc.example.id
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-northeast-1a"
}

// インターネットゲートウェイ
// VPCは隔離されたネットワークであり、単体ではインターネットと接続できない
// インターネットゲートウェイを作成し、VPCとインターネット間で通信ができるようにする
resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id
}

// ルートテーブル
// インターネットゲートウェイだけでは、まだインターネットと通信できない
// ネットワークにデータを流すために、ルーティング情報を管理するルートテーブルが必要
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.example.id
}

// ルート
// ルートテーブルの1レコードに該当
resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id
  gateway_id = aws_internet_gateway.example.id
  destination_cidr_block = "0.0.0.0/0"
}

// どのルートテーブルを使ってルーティングするかは、サブネット単位で判断する
resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}


resource  "aws_subnet" "private" {
  vpc_id  = aws_vpc.example.id
  cidr_block = "10.0.64.0/24"
  availability_zone = "ap-northeast-1a"
  map_public_ip_on_launch = false
}

resource "aws_route_table" "private" {
  vpc_id  = aws_vpc.example.id
}

resource "aws_route_table_association" "private" {
  route_table_id = aws_route_table.private.id
  subnet_id = aws_subnet.private.id
}

// EIP
// NATゲートウェイにはEIP(Elastic IP Address)が必要
// EIPは静的なパブリックIPアドレスを付与するサービス
resource "aws_eip" "nat_gateway" {
  vpc = true
  depends_on = [aws_internet_gateway.example] // 暗黙的な依存関係
}

// NATゲートウェイ
// プライベートネットワークからインターネットへアクセスできるようになる
resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id = aws_subnet.public.id
  depends_on = [aws_internet_gateway.example]
}

resource "aws_route" "private" {
  route_table_id = aws_route_table.private.id
  nat_gateway_id = aws_nat_gateway.example.id
  destination_cidr_block = "0.0.0.0/0"
}
