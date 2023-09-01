variable "ssh_key" {
  default = ""
}

provider "boundary" {
  addr                            = hcp_boundary_cluster.boundary.cluster_url
  password_auth_method_login_name = var.boundary_admin_user
  password_auth_method_password   = random_password.password.result
}

resource "boundary_worker" "controller_led" {
  scope_id    = "global"
  name        = "worker 1"
  description = "self managed worker with controller led auth"
}

// add the worker
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpc.default_security_group_id
} 

resource "aws_security_group_rule" "all" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpc.default_security_group_id
} 

resource "aws_instance" "worker" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id     = module.vpc.public_subnets.0
  key_name = aws_key_pair.deployer.key_name
  associate_public_ip_address = true

  user_data = templatefile("./init.sh",{
    cluster_id = replace(replace(hcp_boundary_cluster.boundary.cluster_url,"https://",""), ".boundary.hashicorp.cloud","")
    worker_token = boundary_worker.controller_led.controller_generated_activation_token
  })

  vpc_security_group_ids = [module.vpc.default_security_group_id]
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file(var.ssh_key)
}