data "terraform_remote_state" "dns" {
  backend = "s3"

  config {
    bucket = "terraform.grimoire"
    key    = "dns.tfstate"
    region = "ca-central-1"
  }
}

resource "aws_route53_record" "znc_ip4" {
  zone_id = "${data.terraform_remote_state.dns.grimoire_ca_zone_id}"
  name    = "znc"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.znc.public_ip}"]
}

resource "aws_route53_record" "znc_ip6" {
  zone_id = "${data.terraform_remote_state.dns.grimoire_ca_zone_id}"
  name    = "znc"
  type    = "AAAA"
  ttl     = "300"
  records = ["${aws_instance.znc.ipv6_addresses}"]
}
