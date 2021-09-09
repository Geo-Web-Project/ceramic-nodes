resource "digitalocean_droplet" "ipfs-preload" {
    image = 78848161
    name = "ipfs-preload"
    region = "sfo3"
    size = "s-1vcpu-2gb"
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

resource "digitalocean_domain" "ipfs" {
  name       = "ipfs.geoweb.network"
  ip_address = digitalocean_droplet.ipfs-preload.ipv4_address
}


resource "digitalocean_domain" "ipfs-preload" {
  name       = "preload.ipfs.geoweb.network"
  ip_address = digitalocean_loadbalancer.public.ip
}

resource "digitalocean_certificate" "cert" {
  name    = "ipfs-preload"
  type    = "lets_encrypt"
  domains = ["preload.ipfs.geoweb.network"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "digitalocean_loadbalancer" "public" {
  name   = "ipfs-preload-lb"
  region = "sfo3"

  forwarding_rule {
    entry_port     = 443
    entry_protocol = "https"

    target_port     = 80
    target_protocol = "http"

    certificate_name = digitalocean_certificate.cert.name
  }

  forwarding_rule {
    entry_port     = 4002
    entry_protocol = "https"

    target_port     = 4002
    target_protocol = "http"

    certificate_name = digitalocean_certificate.cert.name
  }

  healthcheck {
    port     = 22
    protocol = "tcp"
  }

  droplet_ids = [digitalocean_droplet.ipfs-preload.id]
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
    protocol         = "tcp"
    port_range       = "4001"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "4002"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
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