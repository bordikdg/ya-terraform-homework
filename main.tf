terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  service_account_key_file = "key.json"
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = "ru-central1-a"
}

resource "yandex_iam_service_account" "alb-logging-sa" {
  name        = "alb-logging-service-account"
  description = "service account for function"
  folder_id   = var.folder_id
}

resource "yandex_resourcemanager_folder_iam_member" "alb-logging-sa-editor" {
  folder_id   = var.folder_id
  role        = "editor"
  member      = "serviceAccount:${yandex_iam_service_account.alb-logging-sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "alb-logging-sa-invoker" {
  folder_id   = var.folder_id
  role        = "functions.functionInvoker"
  member      = "serviceAccount:${yandex_iam_service_account.alb-logging-sa.id}"
}
