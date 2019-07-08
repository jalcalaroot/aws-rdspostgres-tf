#################################################
# Definimos las claves de acceso a la API de AWS
#################################################

provider "aws" {
  access_key = "${var.access_key}" 
  secret_key = "${var.secret_key}"
  region     = "us-east-1" 
}

#------------------------------------------------------------
###################
# subnet_group
###################
resource "aws_db_subnet_group" "rds" {
  name        = "${var.rdsname}-subnet-group"
  description = "Our main group of subnets for rds"
  subnet_ids  = ["${var.subnetid_1}", "${var.subnetid_2}", "${var.subnetid_3}"]

  tags = {
    Name  = "${var.rdsname}-subnet-group"
  }
}
#------------------------------------------------------------
####################
# Security Group
####################

resource "aws_security_group" "default" {
  name        = "${var.rdsname}-rds-sg"
  description = "Allow all inbound traffic"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "TCP"
    cidr_blocks = ["10.0.0.0/16"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.rdsname}-rds-sg"
  }
}
#-----------------------------------------------
#DB
resource "aws_db_instance" "rds" {
  allocated_storage      = "100"
  engine                 = "postgres"
  engine_version         = "9.6.6"
  instance_class         = "db.t2.medium"
  name                   = "${var.rdsname}"
  identifier             = "${var.rdsname}"
  username               = "workia"
  password               = "workia2018"
  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  db_subnet_group_name   = "${var.rdsname}-subnet-group"
  publicly_accessible    = false
  multi_az               = "false"
  maintenance_window     = "sun:02:30-sun:03:00"
  backup_window          =  "03:15-03:45"
  backup_retention_period = 7
  storage_type           = "gp2"
  auto_minor_version_upgrade = "false"
  skip_final_snapshot = "true"
  depends_on 		 = ["aws_db_subnet_group.rds"]
  tags { 
    Name = "${var.rdsname}"
  }
}

