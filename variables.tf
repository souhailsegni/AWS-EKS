variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "cluster_name" {
  type    = string
  default = "demo-eks-cluster"
}

variable "vpc_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "az_count" {
  type    = number
  default = 3
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.20.1.0/24","10.20.2.0/24","10.20.3.0/24"]
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.20.101.0/24","10.20.102.0/24","10.20.103.0/24"]
}

variable "cluster_version" {
  type    = string
  default = "1.33"
}

variable "node_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "node_min" {
  type    = number
  default = 2
}

variable "node_max" {
  type    = number
  default = 2
}

variable "node_desired" {
  type    = number
  default = 2
}

# Optional SSH Key to access EKS nodes
variable "ssh_key_name" {
  type        = string
  default     = null
  description = "Optional EC2 Key Pair name for SSH access to worker nodes"
}
