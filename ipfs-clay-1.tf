resource "digitalocean_droplet" "ipfs_clay_1" {
    image = "ubuntu-20-04-x64"
    name = "ipfs-clay-1"
    region = "sfo3"
    size = "s-1vcpu-2gb"
    private_networking = true
    backups = true
    ssh_keys = [
      data.digitalocean_ssh_key.terraform.id
    ]
    connection {
        host = self.ipv4_address
        user = "root"
        type = "ssh"
        private_key = file(var.pvt_key)
        timeout = "2m"
    }
    provisioner "remote-exec" {
        inline = [
        "export PATH=$PATH:/usr/bin",
        "sudo apt-get update",
        "sudo apt-get -y install npm",
        "sudo npm install -g n",
        "sudo n stable"
        ]
    }
}

resource "digitalocean_domain" "ipfs_clay_1" {
  name       = "ipfs-clay-1.nodes.geoweb.network"
  ip_address = digitalocean_droplet.ipfs_clay_1.ipv4_address
}

resource "digitalocean_firewall" "ceramic_firewall" {
  name = "ceramic-node"

  droplet_ids = [digitalocean_droplet.ipfs_clay_1.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["192.168.1.0/24", "2002:1:2::/48"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "4011"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "7007"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol         = "tcp"
    port_range       = "4011"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}