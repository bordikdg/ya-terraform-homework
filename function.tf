resource "yandex_function" "alb-logging-function" {
  name               = "alb-logging-function"
  description        = "Logging function"
  user_hash          = "first-function"
  runtime            = "python312"
  entrypoint         = "function.handler"
  memory             = "128"
  execution_timeout  = "10"
  service_account_id = yandex_iam_service_account.alb-logging-sa.id
  environment = {
    VERBOSE_LOG = "True"
    DB_HOSTNAME = "${yandex_mdb_postgresql_cluster.pgsql-alb-logging.host[0].fqdn}"
    DB_PORT     = "6432"
    DB_NAME     = "${yandex_mdb_postgresql_database.db-logging.name}"
    DB_USER     = "${yandex_mdb_postgresql_user.mdb-alb-logging.name}"
    DB_PASSWORD = "${yandex_mdb_postgresql_user.mdb-alb-logging.password}"
  }

  content {
    zip_filename = "function.zip"
  }
}

resource "yandex_function_trigger" "alb-logging-trigger" {
  name      = "alb-logging-trigger"
  folder_id = var.folder_id

  function {
    id                 = yandex_function.alb-logging-function.id
    service_account_id = yandex_iam_service_account.alb-logging-sa.id
    tag                = "$latest"

  }
  logging {
    group_id       = yandex_logging_group.alb-logging-group.id
    resource_types = ["alb.loadBalancer"]
    batch_cutoff   = "15"
    batch_size     = "10"
  }

}
