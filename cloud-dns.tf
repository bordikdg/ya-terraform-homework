resource "yandex_dns_zone" "alb-zone" {
  name        = "alb-zone"
  description = "Public zone"
  zone        = var.dns_zone
  public      = true
}

resource "yandex_dns_recordset" "rs1" {
  zone_id = yandex_dns_zone.alb-zone.id
  name    = var.dns_zone
  ttl     = 200
  type    = "A"
  data    = [yandex_alb_load_balancer.alb-1.listener[0].endpoint[0].address[0].external_ipv4_address[0].address]
}

resource "yandex_dns_recordset" "rs2" {
  zone_id = yandex_dns_zone.alb-zone.id
  name    = "www"
  ttl     = 200
  type    = "A"
  data    = [yandex_alb_load_balancer.alb-1.listener[0].endpoint[0].address[0].external_ipv4_address[0].address]
}
