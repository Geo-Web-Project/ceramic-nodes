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