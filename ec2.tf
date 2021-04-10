# security group for EC2 instances
resource "aws_security_group" "webserver_default_ec2_security_group" {
  name        = "webserver_default_ec2_security_group"
  description = "allow incoming HTTP traffic only"
//  vpc_id      = aws_vpc.default.id
  vpc_id = local.vpc_id

  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "webserver_default_ec2_security_group"
  }
}

# EC2 instances, one per availability zone
resource "aws_instance" "webserver_default" {
  ami                         = lookup(var.ec2_amis, var.aws_region)
  key_name                    = aws_key_pair.invideo_public_key.key_name
  associate_public_ip_address = false
  count                       = length(var.azs)
  depends_on                  = [aws_subnet.public]
  instance_type               = "t2.micro"
  subnet_id                   = element(aws_subnet.public.*.id,count.index)
  user_data                   = file("user_data.sh")
  root_block_device {
    volume_type     = "gp2"
    volume_size     = 8
    delete_on_termination   = true
  }
  # references security group created above
  vpc_security_group_ids = [aws_security_group.webserver_default_ec2_security_group.vpc_id]

  tags = {
    Name = "webserver-nginx-default-instance-${count.index}"
  }
}

resource "aws_ebs_volume" "document_root" {
  availability_zone = length(var.azs)
  size              = 1
  type = "gp2"
  tags = {
    Name = "ebs_document_root"
  }
}
resource "aws_volume_attachment" "document_root_mount" {
  device_name = "/dev/xvdb"
  volume_id   = aws_ebs_volume.document_root.id
  instance_id = aws_instance.webserver_default.id
  connection {
    type    = "ssh"
    user    = "ubuntu"
    host    = aws_instance.webserver_default.public_ip
    port    = 22
    private_key = tls_private_key.invideo_private_key.private_key_pem
  }
  provisioner "remote-exec" {
    inline  = [
      "sudo mkfs.ext4 /dev/xvdb",
      "sudo mount /dev/xvdb /var/www/html",
      "sudo git clone https://github.com/devil-test/webserver-test.git /temp_repo",
      "sudo cp -rf /temp_repo/* /var/www/html",
      "sudo rm -rf /temp_repo",
      "sudo setenforce 0"
    ]
  }
  provisioner "remote-exec" {
    when    = destroy
    inline  = [
      "sudo umount /var/www/html"
    ]
  }
}
