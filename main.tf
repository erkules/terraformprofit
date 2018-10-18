variable "instance_count" { default = 1 }
variable "worker_ram" { default = 4096 }
variable "worker_cores" { default = 2 }
variable "master_ram" { default = 2048 }
variable "master_cores" { default = 2 }
variable "ssh_key_path" 

provider "profitbricks" {
  username = "<USERNAME>"
  password = "<PBPASSWORD>"
}

resource "profitbricks_datacenter" "example" {
  name        = "LALA"
  location    = "de/fra"
  description = "datacenter description"
}

  resource "profitbricks_ipblock" "example" {
    location = "${profitbricks_datacenter.example.location}"
    size     = 1
  }

resource "profitbricks_lan" "example" {
  datacenter_id = "${profitbricks_datacenter.example.id}"
  public        = true
}

resource "profitbricks_lan" "intern" {
  datacenter_id = "${profitbricks_datacenter.example.id}"
  public        = false
}


  resource "profitbricks_server" "example" {
    name              = "master"
    datacenter_id     = "${profitbricks_datacenter.example.id}"
    cores             = "${var.master_cores}"
    ram               = "${var.master_ram}"
    availability_zone = "ZONE_1"
    cpu_family        = "AMD_OPTERON"
    ssh_key_path   = ["${var.ssh_key_path}"]
  
    volume {
      name           = "new"
      #image_name     = "Debian-8-server-2018-10-01"
      image_name     = "Ubuntu-16.04-LTS-server-2018-10-01"
      size           = 5
      disk_type      = "SSD"
    }
    
    nic {
      lan             = "${profitbricks_lan.example.id}"
      dhcp            = true
      firewall_active = false
  
    }
  }

resource "profitbricks_nic" "example" {
  datacenter_id = "${profitbricks_datacenter.example.id}"
  server_id     = "${profitbricks_server.example.id}"
  lan           = "${profitbricks_lan.intern.id}"
  dhcp          = true
}

resource "profitbricks_server" "worker" {
    name              = "worker${count.index}"
    count             = "${var.instance_count}"
    datacenter_id     = "${profitbricks_datacenter.example.id}"
    cores             = "${var.worker_cores}"
    ram               = "${var.worker_ram}"
    availability_zone = "ZONE_1"
    cpu_family        = "AMD_OPTERON"
    ssh_key_path   = ["${var.ssh_key_path}"]
  
    volume {
      name           = "new"
      image_name     = "Ubuntu-16.04-LTS-server-2018-10-01"
      size           = 5
      disk_type      = "SSD"
    }
  
    nic {
      lan             = "${profitbricks_lan.intern.id}"
      dhcp            = true
      firewall_active = false
    }
}

