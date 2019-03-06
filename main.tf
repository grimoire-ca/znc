locals {
  user_data_tpl = "${file("${path.module}/templates/user_data")}"

  initialize_znc       = "${file("${path.module}/sbin/initialize-znc")}"
  make_znc_bundle      = "${file("${path.module}/sbin/make-znc-bundle")}"
  ebs_auto_filesystem  = "${file("${path.module}/sbin/ebs-auto-filesystem")}"
  auto_partition_rules = "${file("${path.module}/udevd/10-auto-partition.rules")}"

  znc_service = "${file("${path.module}/units/znc.service")}"

  znc_cert_hook = "${file("${path.module}/letsencrypt/znc.deploy-hook")}"
}

data "template_file" "user_data" {
  # Render the template once for each instance
  template = "${local.user_data_tpl}"

  vars {
    hostname = "znc"

    initialize_znc       = "${base64encode(local.initialize_znc)}"
    make_znc_bundle      = "${base64encode(local.make_znc_bundle)}"
    ebs_auto_filesystem  = "${base64encode(local.ebs_auto_filesystem)}"
    auto_partition_rules = "${base64encode(local.auto_partition_rules)}"

    znc_service = "${base64encode(local.znc_service)}"

    znc_cert_hook = "${base64encode(local.znc_cert_hook)}"
  }
}

resource "aws_key_pair" "znc" {
  key_name   = "znc"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCflLpEFah1USN0edydDRXy5y1H3uVlVqfcRXBDSt3/Q+tO1ilR7x6qkqFUJGr2YpxG9AI45XimqI1Q1RoYHWI0cbDBOF6m9F8flrmIRZL2WkX0Ul5HBLFcbXs40eo6jXuV7Mom1cvLVvp5H/zsSutN3RwG/Q81Psv04ZX8xQHPlYnTOigzrUPsYWLciLiQ269s5dI4lDgQTwEIlou0PHgtMwBlWLGNIFpTY/mMgv7tIqNiRtXVEukYGeDp605+OX8Rf5S0JkKxdqij9HS1noYcAo/XN5jk5MCbtY5vnkc6nAm7xlwzq5RNggkgnTe/UpWM0fOsznUwi6Np8eXpWKDz owen@grimoire.ca"
}

resource "aws_instance" "znc" {
  availability_zone = "ca-central-1b"

  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t3.nano"

  vpc_security_group_ids = ["${aws_security_group.znc.id}"]

  key_name = "${aws_key_pair.znc.key_name}"

  subnet_id = "${data.terraform_remote_state.network.subnet_id}"

  user_data = "${data.template_file.user_data.rendered}"

  tags {
    Project = "znc"
  }
}

resource "aws_volume_attachment" "znc" {
  device_name = "/dev/sdz"
  volume_id   = "${aws_ebs_volume.znc.id}"
  instance_id = "${aws_instance.znc.id}"
}

output "instance_ip" {
  value = "${aws_instance.znc.public_ip}"
}
