resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_security_group_rule" "postgres" {
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpc.default_security_group_id
} 

resource "aws_rds_cluster" "postgres" {
  cluster_identifier      = "aurora-cluster"
  engine                  = "aurora-postgresql"
  availability_zones      = var.regions
  database_name           = "mydb"
  master_username         = "myuser"
  master_password         = random_password.db_password.result
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  db_subnet_group_name = module.vpc.database_subnet_group_name
  skip_final_snapshot = true
}

resource "aws_rds_cluster_instance" "test1" {
  apply_immediately  = true
  cluster_identifier = aws_rds_cluster.postgres.id
  identifier         = "test1"
  instance_class     = "db.t3.medium"
  engine             = aws_rds_cluster.postgres.engine
  engine_version     = aws_rds_cluster.postgres.engine_version
}

resource "aws_rds_cluster_endpoint" "static" {
  cluster_identifier          = aws_rds_cluster.postgres.id
  cluster_endpoint_identifier = "static"
  custom_endpoint_type        = "READER"

  static_members = [
    aws_rds_cluster_instance.test1.id,
  ]
}