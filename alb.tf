resource "yandex_alb_backend_group" "alb-bg-a" {
  name = "alb-bg-a"

  http_backend {
    name             = "backend-a"
    port             = 80
    target_group_ids = [yandex_compute_instance_group.group-vms-a.application_load_balancer.0.target_group_id]
    healthcheck {
      timeout          = "10s"
      interval         = "2s"
      healthcheck_port = 80
      http_healthcheck {
        path = "/"
      }
    }
  }
}

resource "yandex_alb_backend_group" "alb-bg-b" {
  name = "alb-bg-b"

  http_backend {
    name             = "backend-b"
    port             = 80
    target_group_ids = [yandex_compute_instance_group.group-vms-b.application_load_balancer.0.target_group_id]
    healthcheck {
      timeout          = "10s"
      interval         = "2s"
      healthcheck_port = 80
      http_healthcheck {
        path = "/"
      }
    }
  }
}

resource "yandex_alb_backend_group" "alb-bg-ab" {
  name = "alb-bg-ab"

  http_backend {
    name             = "backend-ab"
    port             = 80
    target_group_ids = [yandex_compute_instance_group.group-vms-a.application_load_balancer.0.target_group_id, yandex_compute_instance_group.group-vms-b.application_load_balancer.0.target_group_id]
    healthcheck {
      timeout          = "10s"
      interval         = "2s"
      healthcheck_port = 80
      http_healthcheck {
        path = "/"
      }
    }
  }
}


resource "yandex_alb_http_router" "alb-router" {
  name = "alb-router"
}

resource "yandex_alb_virtual_host" "alb-host" {
  name           = "alb-host"
  http_router_id = yandex_alb_http_router.alb-router.id
  authority      = [var.domain, "www.${var.domain}"]


  route {
    name = "route"
    http_route {
      http_match {
        http_method = []
        path {
          exact = "/"
        }
      }
      http_route_action {
        backend_group_id = yandex_alb_backend_group.alb-bg-ab.id
      }
    }
  }

  route {
    name = "route-a"
    http_route {
      http_match {
        path {
          prefix = "/page1.html"
        }
      }
      http_route_action {
        prefix_rewrite   = "/index2.html"
        backend_group_id = yandex_alb_backend_group.alb-bg-a.id
      }
    }
  }

  route {
    name = "route-b"
    http_route {
      http_match {
        path {
          prefix = "/page2.html"
        }
      }
      http_route_action {
        prefix_rewrite   = "/index2.html"
        backend_group_id = yandex_alb_backend_group.alb-bg-b.id
      }
    }
  }
}


resource "yandex_alb_load_balancer" "alb-1" {
  name               = "alb-1"
  network_id         = yandex_vpc_network.tf-vpc.id
  security_group_ids = [yandex_vpc_security_group.tf-sg-1.id]

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.tf-vpc-subnet-a.id
    }

    location {
      zone_id   = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.tf-vpc-subnet-b.id
    }
  }

  log_options {
    log_group_id = yandex_logging_group.alb-logging-group.id
  }

  listener {
    name = "alb-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.alb-router.id
      }
    }
  }
}

resource "yandex_logging_group" "alb-logging-group" {
  name             = "alb-logging-group"
  folder_id        = var.folder_id
  retention_period = "12h"
}

