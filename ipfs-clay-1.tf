resource "digitalocean_droplet" "ipfs-clay-1" {
    image = "ubuntu-20-04-x64"
    name = "ipfs-clay-1"
    region = "sfo3"
    size = "s-1vcpu-1gb"
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
        "sudo apt-get -y install npm"
        ]
    }
}