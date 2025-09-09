data "aws_ami" "prometheus" {
  owners      = [var.ami_owner_id]
  most_recent = true
  name_regex  = "^prometheus-ami-${var.ami_version_pattern}$"

  filter {
    name   = "name"
    values = ["prometheus-ami-*"]
  }
}

resource "aws_instance" "prometheus" {
  count                  = var.instance_count

  ami                    = data.aws_ami.prometheus.id
  iam_instance_profile   = aws_iam_instance_profile.prometheus.name
  instance_type          = var.instance_type
  key_name               = var.ssh_keyname
  subnet_id              = element(var.subnet_ids, count.index)
  user_data_base64       = data.template_cloudinit_config.prometheus.*.rendered[count.index]
  vpc_security_group_ids = [aws_security_group.prometheus.id]

  root_block_device {
    volume_size = var.root_volume_size != 0 ? var.root_volume_size : local.ami_root_block_device.ebs.volume_size
  }

  dynamic "ebs_block_device" {
    for_each = local.ami_lvm_block_devices
    iterator = block_device
    content {
      device_name = block_device.value.device_name
      encrypted   = block_device.value.ebs.encrypted
      iops        = block_device.value.ebs.iops
      snapshot_id = block_device.value.ebs.snapshot_id
      volume_size = var.lvm_block_devices[index(var.lvm_block_devices.*.lvm_physical_volume_device_node, block_device.value.device_name)].aws_volume_size_gb
      volume_type = block_device.value.ebs.volume_type
    }
  }

  tags = {
    Environment = var.environment
    HostName    = "${var.service}-${var.environment}-prometheus-${count.index + 1}.${var.dns_zone_name}"
    Name        = "${var.service}-${var.environment}-prometheus-${count.index + 1}"
    Service     = var.service
  }

  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }
}
