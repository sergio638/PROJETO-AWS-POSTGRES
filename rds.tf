resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = {
    Name = "My DB subnet group"
  }
}


# IAM Role para habilitar o enhanced monitoring

resource "aws_iam_role" "rds_enhanced_monitoring" {
  name_prefix        = "rds-enhanced-monitoring-"
  assume_role_policy = data.aws_iam_policy_document.rds_enhanced_monitoring.json
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  role       = aws_iam_role.rds_enhanced_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

data "aws_iam_policy_document" "rds_enhanced_monitoring" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_db_parameter_group" "default" {
  name   = "rds-pg"
  family = "postgres12.5"

  parameter {
    name  = "log_statement"
    value = "all"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1"
  }
}

# DB Master

resource "aws_db_instance" "postgre" {
  allocated_storage    = 10
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = var.engine_version
  instance_class       = "db.t3.medium"
  name                 = "mydb"
  username             = "sergio"
  password             = "secret"
  multi_az             = true
  parameter_group_name = var.parameter_group
  skip_final_snapshot  = true
  performance_insights_enabled = true
  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"
  backup_retention_period = 1
  monitoring_interval             = var.monitoring_interval
  monitoring_role_arn             = aws_iam_role.rds_enhanced_monitoring.arn
  deletion_protection             = var.deletion_protection
  enabled_cloudwatch_logs_exports = var.cloudwatch_logs_exports

  db_subnet_group_name = aws_db_subnet_group.default.id
  vpc_security_group_ids  = [aws_security_group.db.id]
  
  
}

# DB Replica 

resource "aws_db_instance" "postgre-replica" {

  replicate_source_db = aws_db_instance.postgre.id
  allocated_storage    = 10
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = var.engine_version
  instance_class       = "db.t3.medium"
  name                 = "mydb"
  username             = ""
  password             = ""
  multi_az             = true
  parameter_group_name = var.parameter_group
  skip_final_snapshot  = true
  performance_insights_enabled = true
  maintenance_window = "Tue:00:00-Tue:03:00"
  backup_window      = "03:00-06:00"
  backup_retention_period = 0
  

  #db_subnet_group_name = aws_db_subnet_group.default.id
  vpc_security_group_ids  = [aws_security_group.db.id]
}

#Cloudwatch
# Utilização de CPU

 resource "aws_cloudwatch_metric_alarm" "database_cpu" {
  alarm_name          = "postgres_cpu"
  alarm_description   = "Database server CPU utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.alarm_cpu_threshold

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.postgre.id
  }
}

# Espaço em disco livre

resource "aws_cloudwatch_metric_alarm" "database_disk_free" {
  alarm_name          = "postgre_disk"
  alarm_description   = "Database server free storage space"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = var.alarm_free_disk_threshold

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.postgre.id
  }
}

# Memória Livre

  resource "aws_cloudwatch_metric_alarm" "database_memory_free" {
  alarm_name          = "postgre_memory"
  alarm_description   = "Database server freeable memory"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = var.alarm_free_memory_threshold

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.postgre.id
  } 
}  

