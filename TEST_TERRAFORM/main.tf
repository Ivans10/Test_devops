provider "aws" {
  profile = "TEST"
  region  = "eu-west-1"
}

terraform {
  backend "s3" {
    region  = "eu-west-1"
    bucket  = "s3b-test-terraform-state"
    key     = "tf-state/network-test.tfstate"
    profile = "TEST"
  }
}

#---Modules---#
module "eks" {
  source = "./modules/eks/*"

  cluster_name    = var.cluster_name
  vpc_id          = var.vpc_id
  subnet_ids      = var.subnet_ids
  cidr_block         = "10.0.0.0/16"
  public_subnet_cidr = "10.0.1.0/24"
  availability_zone  = "eu-central-1a"
  environment        = "my-eks-env"

}

module "rds" {
  source = "./modules/rds/*"

  db_name              = "rds-name"
  engine               = "mysql"
  engine_version       = "8.0"
  family               = "mysql8.0"
  major_engine_version = "8.0"
  instance_class       = "db.t3.micro"

  allocated_storage           = 20
  max_allocated_storage       = 100
  manage_master_user_password = false

  username = var.db_username
  password = var.db_password
  port     = 3306

  multi_az               = false
  db_subnet_group_name   = aws_db_subnet_group.database_subnet.name
  vpc_security_group_ids = [module.db_security_group.security_group_id]

  skip_final_snapshot = true
  deletion_protection = false

  name_db_sg  = "MySQL Database security group"
  description = "Security group for MySQL"
  vpc_id      = data.aws_vpc.infrastructure_vpc.id

  ingress_with_cidr_blocks = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = " "
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      description = " "
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "rds-proxy" {
  source = "./modules/rds-proxy/*"

  name                   = "my-rds-proxy"
  iam_role_name          = "rds-proxy-role"
  vpc_subnet_ids         = [data.aws_subnet.first_subnet.id, data.aws_subnet.second_subnet.id]
  vpc_security_group_ids = [module.db_security_group.security_group_id]

  auth = {
    "${var.db_name}" = {
      description = "RDS MySQL superuser password"
      secret_arn  = module.secrets_manager.secret_arn
    }
  }

  # Target MySQL Instance
  engine_family = "MYSQL"
  debug_logging = true

  # Target RDS instance
  target_db_instance     = true
  db_instance_identifier = module.db.db_instance_identifier

  tags = {
    Terraform   = "true"
    Environment = "Test"
  }
}

module "secret-manager" {
  source = "./modules/secrets-manager/*"

  # Secret
  name_prefix             = "mydb-secret"
  description             = "MySQL Secrets"
  recovery_window_in_days = 30

  # Policy
  create_policy       = true
  block_public_policy = true
  policy_statements = {
    read = {
      sid = "AllowAccountRead"
      principals = [{
        type        = "AWS"
        identifiers = ["arn:aws:iam::xxxxxxxxx:root"]
      }]
      actions   = ["secretsmanager:GetSecretValue"]
      resources = ["*"]
    }
  }

  secret_string = jsonencode({
    username = "${var.db_username}"
    password = "${var.db_password}"
  })

}