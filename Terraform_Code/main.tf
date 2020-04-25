
//Creating custom VPC
resource "aws_vpc" "VPC" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = "true"
  tags = {
    Name = "MY_VPC"
  }
}

//Creating public subnet
resource "aws_subnet" "SUBNET" {
  vpc_id    = "${aws_vpc.VPC.id}"
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "PUBLIC_SUBNET"
  }
}

//Creating gateway
resource "aws_internet_gateway" "IGW" {
  vpc_id = "${aws_vpc.VPC.id}"
  tags {
      Name = "MY_IGW"
    }
}
//Creating CRT
resource "aws_route_table" "CRT" {
    vpc_id = "${aws_vpc.VPC.id}"
    
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0" 
        //CRT uses this IGW to reach internet
        gateway_id = "${aws_internet_gateway.IGW.id}" 
    }
    
    tags {
        Name = "MY_CRT"
    }
}
resource "aws_route_table_association" "CRT_PUBLIC_SUBNET_ASSOCIATION"{
    subnet_id = "${aws_subnet.SUBNET.id}"
    route_table_id = "${aws_route_table.CRT.id}"
}

resource "aws_security_group" "WEB_SG" {
  vpc_id = "${aws_vpc.VPC.id}"
  name = "MY_WEB_SG"
  ingress {
    to_port     = 80
    from_port   = 80
    protocol    = "TCP"
    cidr_blocks = ["${var.MY_IP}"]
  }

  egress {
    to_port     = 80
    from_port   = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    to_port     = 443
    from_port   = 443
    protocol    = "TCP"
    cidr_blocks = ["${var.MY_IP}"]
  }

  egress {
    to_port     = 443
    from_port   = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
      
  }

  ingress {
    to_port     = 22
    from_port   = 22
    protocol    = "TCP"
    cidr_blocks = ["${var.MY_IP}"]
  }

  egress {
    to_port     = 22
    from_port   = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "TCP"
    cidr_blocks = ["${var.MY_IP}"]
  }

  egress {
    from_port = 8080
    to_port = 8080
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags{
    Name = "MY_WEB_SG"
  }
}

 //Creating EC2 instance
resource "aws_instance" "EC2" {
  ami             = "${var.AWS_AMI}"
  instance_type   = "${var.AWS_INSTANCETYPE}"
  subnet_id       = "${aws_subnet.SUBNET.id}"
  vpc_security_group_ids  = ["${aws_security_group.WEB_SG.id}"]
  key_name     =    "${var.AWS_KEY}"
 tags = {  
    Name = "WEB_INSTANCE"
  }
  
  provisioner "file" {
    source      = "${var.SOURCE_FILE}"
    destination = "${var.DESTINATION_FILE}"
  }
 provisioner "remote-exec" {

    inline = [
      "sudo yum update -y",
      "sudo yum install -y ansible --enablerepo=epel",
      "sudo yum install docker python36 httpd -y",
      "ansible-playbook main.yml"
    ]
  }
  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = "${file("${var.ssh_key}")}"
  }
}
resource "aws_eip" "ELASTIC_IP" {
instance = "${aws_instance.EC2.id}"
  }


