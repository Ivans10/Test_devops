provider "aws" {
  region = "eu-north-1"
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
resource "aws_security_group" "test_security_group" {
  name_prefix = "Test-"
  ingress {
    from_port   = 0
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "test_rds_db" {
  engine                 = "mysql"
  db_name                = "Test RDS"
  identifier             = "Test id RDS"
  instance_class         = "db.t2.micro"
  allocated_storage      = 20
  publicly_accessible    = true
  username               = var.db-username
  password               = var.db-password
  vpc_security_group_ids = [aws_security_group.example.id]
  skip_final_snapshot    = true

  tags = {
    Name = "test-db"
  }
}

resource "aws_db_subnet_group" "test_rds_subnet_group" {
  name       = "test_rds"
  subnet_ids = [aws_subnet.myprivatesubnet_1a.id, aws_subnet.myprivatesubnet_1b.id]
  tags = {
    Name = "Test RDS"
  }
}

resource "aws_security_group" "test_rds_security_group" {
  name        = "test_rds_security_group"
  description = "Allow inbound traffic only for MYSQL and all outbound traffic"
  id      = aws_vpc.myvpc.id
  tags = {
    Name = "rds_security_group"
  }
}

resource "aws_vpc_security_group_egress_rule" "test_rds_allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.test_rds_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "test_rds_allow_http_ipv4" {
  security_group_id = aws_security_group.test_rds_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 3306
  ip_protocol       = "tcp"
  to_port           = 3306
}