resource "null_resource" "provision_tlos" {
  triggers {
    subdomain_id = "${aws_route53_record.tlos.id}"
  }

  connection {
    type        = "ssh"
    host        = "${aws_instance.tlos.public_ip}"
    user        = "ec2-user"
    private_key = "${file("${var.key_location}")}"
    agent       = false
  }

  provisioner "file" {
    source      = "update-route53-record.sh"
    destination = "/home/ec2-user/update-route53-record.sh"

  }

  provisioner "file" {
    source      = "update-route53-record.service"
    destination = "/home/ec2-user/update-route53-record.service"

  }

  provisioner "remote-exec" {
    inline = [
      "sudo certbot --nginx certonly -n --domain ${aws_route53_record.tlos.fqdn}",
      "sudo fuser -k 443/tcp",
      "sudo echo '${aws_route53_record.tlos.fqdn}.' > /home/ec2-user/fqdn.out",
      "sudo mv /home/ec2-user/update-route53-record.sh /usr/local/bin/update-route53-record.sh",
      "sudo mv /home/ec2-user/update-route53-record.service /lib/systemd/system/update-route53-record.service",
      "sudo chmod +x /usr/local/bin/update-route53-record.sh",
      "sudo chmod +x /lib/systemd/system/update-route53-record.service",
      "sudo chown root:root /usr/local/bin/update-route53-record.sh",
      "sudo chown root:root /lib/systemd/system/update-route53-record.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable update-route53-record.service",
    ]
  }
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '${aws_instance.tlos.public_ip},' -u ec2-user --private-key ${var.key_location} --extra-vars dns=${aws_route53_record.tlos.fqdn} master.yml"

  }
}
