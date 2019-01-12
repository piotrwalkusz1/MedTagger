## Volumes ##
resource "openstack_blockstorage_volume_v2" "app_volume" {
  name = "App"
  size = 10
}

resource "openstack_blockstorage_volume_v2" "db_volume" {
  name = "Db"
  size = 10
}

resource "openstack_blockstorage_volume_v2" "cass_volume" {
  name = "Cassandra"
  size = 50
}

resource "openstack_blockstorage_volume_v2" "psql_volume" {
  name = "PostreSQL"
  size = 10
}

## Instances ##

## App host ##
resource "openstack_compute_instance_v2" "app" {
  name      = "AppHost"
  image_id  = "${var.image_id}"
  flavor_id = "${var.flavor_id}"
  key_pair  = "${openstack_compute_keypair_v2.medtagger_keypair_app.name}"

  security_groups = [
    "default",
    "${openstack_networking_secgroup_v2.app_sec_group.name}",
  ]

  network {
    uuid = "${openstack_networking_network_v2.network.id}"
  }
}

resource "openstack_compute_floatingip_associate_v2" "fip_1" {
  floating_ip = "${openstack_networking_floatingip_v2.floatip_1.address}"
  instance_id = "${openstack_compute_instance_v2.app.id}"
}

resource "openstack_compute_volume_attach_v2" "app_volume_attach" {
  instance_id = "${openstack_compute_instance_v2.app.id}"
  volume_id   = "${openstack_blockstorage_volume_v2.app_volume.id}"
}

## Db Host ##
resource "openstack_compute_instance_v2" "db" {
  name      = "DbHost"
  image_id  = "${var.image_id}"
  flavor_id = "${var.flavor_id}"
  key_pair  = "${openstack_compute_keypair_v2.medtagger_keypair_db.name}"

  security_groups = [
    "default",
    "${openstack_networking_secgroup_v2.db_sec_group.name}",
  ]

  network {
    uuid = "${openstack_networking_network_v2.network.id}"
  }
}

resource "openstack_compute_volume_attach_v2" "db_volume_attach" {
  instance_id = "${openstack_compute_instance_v2.db.id}"
  volume_id   = "${openstack_blockstorage_volume_v2.db_volume.id}"
}

resource "openstack_compute_volume_attach_v2" "cass_volume_attach" {
  instance_id = "${openstack_compute_instance_v2.db.id}"
  volume_id   = "${openstack_blockstorage_volume_v2.cass_volume.id}"
}

resource "openstack_compute_volume_attach_v2" "psql_volume_attach" {
  instance_id = "${openstack_compute_instance_v2.db.id}"
  volume_id   = "${openstack_blockstorage_volume_v2.psql_volume.id}"
}

## Inventory ##

data "template_file" "inventory" {
  template = "${file("inventory.tpl")}"

  vars {
    app_host_ip = "${openstack_networking_floatingip_v2.floatip_1.address}"
    db_host_ip = "${openstack_compute_instance_v2.db.access_ip_v4}"
    app_key_path = "app.key"
    db_key_path = "db.key"
    default_user = "${var.user}"
  }
}

resource "null_resource" "update_inventory" {

    triggers {
        template = "${data.template_file.inventory.rendered}"
    }

    provisioner "local-exec" {
        command = "echo '${data.template_file.inventory.rendered}' > ../ansible/inventory"
    }
}