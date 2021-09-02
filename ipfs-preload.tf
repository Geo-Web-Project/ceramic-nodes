resource "digitalocean_droplet" "ipfs-preload" {
    image = 78848161
    name = "ipfs-preload"
    region = "sfo3"
    size = "s-1vcpu-1gb"
    private_networking = true
    backups = false
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
}

resource "digitalocean_firewall" "ipfs_firewall" {
  name = "ipfs"

  droplet_ids = [digitalocean_droplet.ipfs-preload.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            =  "1-65535" 
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            =  "1-65535" 
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}