variable "ami_owner_id" {
  type        = string
  description = "The ID of the AMI owner"
}

variable "ami_version_pattern" {
  description = "The pattern with which to match AMIs"
  type        = string
}

variable "certificate_arn" {
  description = "The ARN of the certificate we'll use"
  type        = string
}

variable "dns_zone_name" {
  description = "The name of the DNS zone we're using"
  type        = string
}

variable "environment" {
  description = "The environment name to be used when creating AWS resources"
  type        = string
}

variable "grafana_admin_password" {
  description = "The Grafana admin password used if LDAP connectivity is unavailable"
  type        = string
}

variable "grafana_cidrs" {
  description = "A list of CIDR blocks to permit grafana access from"
  type        = list(string)
}

variable "grafana_service_group" {
  description = "The Linux group name for association with grafana configuration files"
  type        = string
}

variable "grafana_service_user" {
  description = "The Linux username for ownership of grafana configuration files"
  type        = string
}

variable "instance_count" {
  description = "The number of grafana instances to provision"
  type        = number
}

variable "instance_type" {
  description = "The instance type to use"
  type        = string
}

variable "ldap_auth_bind_dn" {
  description = "Bind DN for searching LDAP users and groups"
  type        = string
}

variable "ldap_auth_bind_password" {
  description = "Bind password for the user specified bind DN"
  type        = string
}

variable "ldap_auth_host" {
  description = "The Ldap server host"
  type        = string
}

variable "ldap_auth_port" {
  description = "The LDAP server port"
  type        = string
}

variable "ldap_auth_search_base_dns" {
  description = "An array of base dns to search through"
  type        = string
}

variable "ldap_auth_search_filter" {
  description = "Search user bind dn"
  type        = string
}

variable "ldap_auth_ssl_skip_verify" {
  description = "Ldap SSL cert validation configuration"
  type        = bool
}

variable "ldap_auth_start_tls" {
  description = "Ldap TLS configuration"
  type        = bool
}

variable "ldap_auth_use_ssl" {
  description = "Ldap ssl configuration"
  type        = bool
}

variable "ldap_grafana_admin_group_dn" {
  description = "Ldap group used for admin privileges"
  type        = string
}

variable "ldap_grafana_viewer_group_dn" {
  description = "Ldap group used for viewing privileges"
  type        = string
}

variable "lvm_block_devices" {
  description = "A list of objects representing LVM block devices; each LVM volume group is assumed to contain a single physical volume and each logical volume is assumed to belong to a single volume group; the filesystem for each logical volume will be expanded to use all available space within the volume group using the filesystem resize tool specified; block device configuration applies only on resource creation"
  type = list(object({
    aws_volume_size_gb: string,
    filesystem_resize_tool: string,
    lvm_logical_volume_device_node: string,
    lvm_physical_volume_device_node: string,
  }))
}

variable "placement_subnet_ids" {
  description = "The ids of the subnets into which we'll place grafana instances"
  type = list(string)
}

variable "region" {
  description = "The AWS region in which resources will be administered"
  type        = string
}

variable "root_volume_size" {
  description = "The size of the root volume in GiB; set this value to 0 to preserve the size specified in the AMI metadata. This value should not be smaller than the size specified in the AMI metadata and used by the root volume snapshot. The filesystem will be expanded automatically to use all available space for the volume and an XFS filesystem is assumed"
  type        = number
}

variable "route53_available" {
  description = "A flag indicating whether Route53 is available"
  type        = bool
}

variable "service" {
  description = "The service name to be used when creating AWS resources"
  type        = string
}

variable "ssh_cidrs" {
  description = "The SSH of the CIDR to be used"
  type = list(string)
}

variable "ssh_keyname" {
  description = "The SSH keypair name to use for remote connectivity"
  type        = string
}

variable "ssl_policy" {
  description = "The SSL policy version to be used on the ALB"
  type        = string
}

variable "subnet_ids" {
  description = "The ids of the subnets into which we'll place instances"
  type        = list(string)
}

variable "user_data_merge_strategy" {
  description = "Merge strategy to apply to user-data sections for cloud-init"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID in which to create resources"
  type        = string
}
