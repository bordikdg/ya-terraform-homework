resource "yandex_compute_instance_group" "group-vms-a" {
  name                = "group-vms-a"
  folder_id           = var.folder_id
  service_account_id  = var.service_account_id
  deletion_protection = false
  instance_template {
    platform_id = "standard-v1"
    resources {
      memory = 2
      cores  = 2
    }
    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = var.image_id
      }
    }
    network_interface {
      network_id = yandex_vpc_network.tf-vpc.id
      subnet_ids = [yandex_vpc_subnet.tf-vpc-subnet-a.id]
      nat        = false
    }

    metadata = {
      user-data = "${file("~/terraform/cloud_config_group_vms_a.yaml")}"
    }
    network_settings {
      type = "STANDARD"
    }
  }

  scale_policy {
    fixed_scale {
      size = 2
    }
  }

  allocation_policy {
    zones = ["ru-central1-a"]
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 1
  }
  application_load_balancer {
    target_group_name        = "target-group-vms-a"
    target_group_description = "Target Group App Load Balancer"
  }

}




















