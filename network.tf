resource "yandex_vpc_network" "tf-vpc" {
  name        = "tf-network"
  description = "network_for_tf"
}


resource "yandex_vpc_subnet" "tf-vpc-subnet-a" {
  v4_cidr_blocks = ["10.10.1.0/24"]
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.tf-vpc.id
}


resource "yandex_vpc_subnet" "tf-vpc-subnet-b" {
  v4_cidr_blocks = ["10.10.2.0/24"]
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.tf-vpc.id
}


resource "yandex_vpc_security_group" "tf-sg-1" {
  name        = "tf-sg1"
  description = "security group for alb"
  network_id  = yandex_vpc_network.tf-vpc.id

  ingress {
    protocol       = "TCP"
    description    = "ext-http"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "healthchecks"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 30080
  }

  egress {
    protocol       = "ANY"
    description    = "egress rule description"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "yandex_vpc_security_group" "tf-sg-2" {
  name        = "tf-sg2"
  description = "security group for db cluster"
  network_id  = yandex_vpc_network.tf-vpc.id

  ingress {
    protocol       = "TCP"
    description    = "ingress rule description"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 6432
  }

  egress {
    protocol       = "ANY"
    description    = "egress rule description"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}


