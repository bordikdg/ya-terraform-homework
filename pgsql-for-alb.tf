resource "yandex_mdb_postgresql_cluster" "pgsql-alb-logging" {
  name        = "pgsql-alb-logging"
  environment = "PRODUCTION"

  network_id         = yandex_vpc_network.tf-vpc.id
  security_group_ids = [yandex_vpc_security_group.tf-sg-2.id]

  config {
    version = 12
    resources {
      resource_preset_id = "b2.medium"
      disk_type_id       = "network-ssd"
      disk_size          = 15
    
    }
   access {
    web_sql    = true
    serverless = true

  }
  }

  host {
    zone             = "ru-central1-a"
    subnet_id        = yandex_vpc_subnet.tf-vpc-subnet-a.id
    assign_public_ip = true 
  }
}



resource "yandex_mdb_postgresql_user" "mdb-alb-logging" {
  cluster_id = yandex_mdb_postgresql_cluster.pgsql-alb-logging.id
  name       = "db_admin"
  password   = "Zz12345678"
}

resource "yandex_mdb_postgresql_database" "db-logging" {
  cluster_id = yandex_mdb_postgresql_cluster.pgsql-alb-logging.id
  name       = "db_logging"
  owner      = yandex_mdb_postgresql_user.mdb-alb-logging.name
  lc_collate = "C"
  lc_type    = "C"
  
  provisioner "local-exec" {
    command = "psql -h ${yandex_mdb_postgresql_cluster.pgsql-alb-logging.host[0].fqdn} -p 6432 -d db_logging -U db_admin -f pgsql.sql"
    environment = {
      PGPASSWORD = "${yandex_mdb_postgresql_user.mdb-alb-logging.password}"
    }
  }
}

