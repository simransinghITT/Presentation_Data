variable "AWS_REGION" {    
    default = "ap-south-1"
}
variable "AWS_AMI" {    
    default = "ami-04b2519c83e2a7ea5"
}variable "AWS_KEY" {    
    default = "My_key"
}variable "AWS_INSTANCETYPE" {    
    default = "t2.micro"
}variable "SOURCE_FILE" {    
    default = "./main.yml"
}
variable "DESTINATION_FILE" {    
    default = "/home/ec2-user/main.yml"
}
variable "MY_IP" {
    default = ["182.75.175.234/32"]
  
}
variable "ssh_key" {
}
