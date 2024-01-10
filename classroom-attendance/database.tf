resource "aws_db_instance" "my_db" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  db_name              = "mydatabase"
  username             = "admin"
  password             = "pleasegivemeajob"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.database_sg.id]
}

resource "aws_security_group" "database_sg" {
  name        = "my-db-sg"
  description = "MySQL DB security group"
  vpc_id      = aws_vpc.main.id

  # Ingress: Allow MySQL traffic
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.sg.id]
  }

  # Egress: Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = [aws_subnet.private_az1.id, aws_subnet.private_az2.id, aws_subnet.private_az_db.id]

  tags = {
    Name = "MyDBSubnetGroup"
  }
}
