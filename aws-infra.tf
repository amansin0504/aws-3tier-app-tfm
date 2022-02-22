#Create VPC network
resource "aws_vpc" "safe-vpc-network" {
  cidr_block    = "10.0.0.0/16"
  tags = {
    Name = "safe-vpc"
  }
}

#Create subnets in VPC network
resource "aws_subnet" "websubnet1" {
  vpc_id            = aws_vpc.safe-vpc-network.id
  availability_zone = var.az1
  cidr_block        = "10.0.1.0/24"
}
resource "aws_subnet" "websubnet2" {
  vpc_id            = aws_vpc.safe-vpc-network.id
  availability_zone = var.az2
  cidr_block        = "10.0.2.0/24"
}

resource "aws_subnet" "appsubnet1" {
  vpc_id            = aws_vpc.safe-vpc-network.id
  availability_zone = var.az1
  cidr_block        = "10.0.3.0/24"
}
resource "aws_subnet" "appsubnet2" {
  vpc_id            = aws_vpc.safe-vpc-network.id
  availability_zone = var.az2
  cidr_block        = "10.0.4.0/24"
}

resource "aws_subnet" "dbsubnet1" {
  vpc_id            = aws_vpc.safe-vpc-network.id
  availability_zone = var.az1
  cidr_block        = "10.0.5.0/24"
}
resource "aws_subnet" "dbsubnet2" {
  vpc_id            = aws_vpc.safe-vpc-network.id
  availability_zone = var.az2
  cidr_block        = "10.0.6.0/24"
}

#Create internet gateway
resource "aws_internet_gateway" "internetgateway" {
  vpc_id = aws_vpc.safe-vpc-network.id
  tags = {
    Name = "SafeIGW"
  }
}

#Create Nat gateway
resource "aws_eip" "nateip1" {
  vpc = true
}
resource "aws_nat_gateway" "natgateway1" {
  allocation_id = aws_eip.nateip1.id
  subnet_id     = aws_subnet.websubnet1.id
  tags = {
    Name = "safeNATGW"
  }
  depends_on = [aws_internet_gateway.internetgateway]
}
resource "aws_eip" "nateip2" {
  vpc = true
}
resource "aws_nat_gateway" "natgateway2" {
  allocation_id = aws_eip.nateip2.id
  subnet_id     = aws_subnet.websubnet2.id
  tags = {
    Name = "safeNATGW"
  }
  depends_on = [aws_internet_gateway.internetgateway]
}

#Route tables
resource "aws_route_table" "webRT" {
  vpc_id = aws_vpc.safe-vpc-network.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internetgateway.id
  }
  tags = {
    Name = "webRT"
  }
}
resource "aws_route_table_association" "webRTtowebsubnet1" {
  subnet_id      = aws_subnet.websubnet1.id
  route_table_id = aws_route_table.webRT.id
}
resource "aws_route_table_association" "webRTtowebsubnet2" {
  subnet_id      = aws_subnet.websubnet2.id
  route_table_id = aws_route_table.webRT.id
}

resource "aws_route_table" "appRT1" {
  vpc_id = aws_vpc.safe-vpc-network.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgateway1.id
  }
  tags = {
    Name = "appRT1"
  }
}
resource "aws_route_table_association" "appRT1toappsubnet1" {
  subnet_id      = aws_subnet.appsubnet1.id
  route_table_id = aws_route_table.appRT1.id
}

resource "aws_route_table" "appRT2" {
  vpc_id = aws_vpc.safe-vpc-network.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgateway2.id
  }
  tags = {
    Name = "appRT2"
  }
}
resource "aws_route_table_association" "appRT2toappsubnet2" {
  subnet_id      = aws_subnet.appsubnet2.id
  route_table_id = aws_route_table.appRT2.id
}

resource "aws_route_table" "dbRT1" {
  vpc_id = aws_vpc.safe-vpc-network.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgateway1.id
  }
  tags = {
    Name = "dbRT1"
  }
}
resource "aws_route_table_association" "dbRT1todbsubnet1" {
  subnet_id      = aws_subnet.dbsubnet1.id
  route_table_id = aws_route_table.dbRT1.id
}

resource "aws_route_table" "dbRT2" {
  vpc_id = aws_vpc.safe-vpc-network.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgateway2.id
  }
  tags = {
    Name = "dbRT2"
  }
}
resource "aws_route_table_association" "dbRT2todbsubnet2" {
  subnet_id      = aws_subnet.dbsubnet2.id
  route_table_id = aws_route_table.dbRT2.id
}

#Create RDS SQL DB
resource "aws_db_subnet_group" "safedbgroup" {
  depends_on = [aws_subnet.dbsubnet1,aws_subnet.dbsubnet1]
  name       = "safedbgroup"
  subnet_ids = [aws_subnet.dbsubnet1.id, aws_subnet.dbsubnet2.id]
  tags = {
    Name = "RDS DB subnet group"
  }
}
resource "aws_db_instance" "saferdsdb" {
  depends_on = [aws_db_subnet_group.safedbgroup]
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "8.0.27"
  instance_class       = "db.t3.micro"
  db_name              = "saferdsdb"
  username             = var.user
  password             = var.password
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.safedbgroup.name
}

#Create App launch config, auto scale group with appLB
resource "aws_lb_target_group" "appworkloadpool" {
  name     = "appworkloadpool"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.safe-vpc-network.id
}
resource "aws_lb" "appNLB" {
  depends_on = [aws_subnet.appsubnet1,aws_subnet.appsubnet1]
  name               = "appNLB"
  load_balancer_type = "network"
  internal           = true
  subnet_mapping {
    subnet_id            = aws_subnet.appsubnet1.id
    private_ipv4_address = "10.0.3.100"
  }
  subnet_mapping {
    subnet_id            = aws_subnet.appsubnet2.id
    private_ipv4_address = "10.0.4.100"
  }
}
resource "aws_lb_listener" "appworkloadtarget" {
  load_balancer_arn = aws_lb.appNLB.arn
  port              = "80"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.appworkloadpool.arn
  }
}

data "template_file" "appinit" {
  depends_on = [aws_db_instance.saferdsdb]
  template = file("app-startup.sh")
  vars = {
    user = var.user
    password = var.password
    database = var.dbname
    host = aws_db_instance.saferdsdb.address
  }
}
resource "aws_launch_configuration" "apptemplate" {
  name          = "apptemplate"
  image_id      = var.images[var.region]
  instance_type = "t2.micro"
  key_name      = var.keyname
  user_data     = data.template_file.appinit.rendered
}

resource "aws_autoscaling_group" "appGroup" {
  depends_on = [aws_launch_configuration.apptemplate,aws_lb.appNLB, aws_lb_target_group.appworkloadpool]
  name                      = "appworkloads"
  max_size                  = 2
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  launch_configuration      = aws_launch_configuration.apptemplate.name
  vpc_zone_identifier       = [aws_subnet.appsubnet1.id,aws_subnet.appsubnet2.id]
  target_group_arns         = [aws_lb_target_group.appworkloadpool.arn]
}

#Create Web Scale Group with webLB

#If requited add Security groups
#Enable VPC flow logs for s3 bucket