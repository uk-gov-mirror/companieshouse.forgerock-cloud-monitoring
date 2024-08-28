variable "account_name" {
  description = "The name of the AWS account we're using"
  type        = string
}

variable "ami_owner_id" {
  type        = string
  description = "The ID of the AMI owner"
}

variable "environment" {
  description = "The environment name to be used when creating AWS resources"
  type        = string
}

variable "grafana_ami_version_pattern" {
  default     = "\\d.\\d.\\d"
  description = "The pattern with which to match grafana AMIs"
  type        = string
}

variable "grafana_instance_count" {
  default     = 1
  description = "The number of grafana instances to provision"
  type        = number
}

variable "grafana_instance_type" {
  default     = "t3.medium"
  description = "The instance type to use for grafana instances"
  type        = string
}

variable "grafana_lvm_block_devices" {
  description = "LVM block devices for grafana nodes"
  type = list(object({
    aws_volume_size_gb: string,
    filesystem_resize_tool: string,
    lvm_logical_volume_device_node: string,
    lvm_physical_volume_device_node: string,
  }))
}

variable "grafana_root_volume_size" {
  default     = 0
  description = "The size of the root volume for grafana instances in GiB; set this value to 0 to preserve the size specified in the AMI metadata. This value should not be smaller than the size specified in the AMI metadata and used by the root volume snapshot. The filesystem will be expanded automatically to use all available space for the volume and an XFS filesystem is assumed"
  type        = number
}

variable "grafana_service_group" {
  default     = "grafana"
  description = "The Linux group name for association with grafana configuration files"
  type        = string
}

variable "grafana_service_user" {
  default     = "grafana"
  description = "The Linux username for ownership of grafana configuration files"
  type        = string
}

variable "ldap_auth_use_ssl" {
  default     = "false"
  description = "Ldap ssl configuration"
  type        = bool
}

variable "ldap_auth_start_tls" {
  default     = "false"
  description = "Ldap TLS configuration"
  type        = bool
}

variable "ldap_auth_ssl_skip_verify" {
  default     = "true"
  description = "Ldap SSL cert validation configuration"
  type        = bool
}

variable "region" {
  description = "The AWS region in which resources will be administered"
  type        = string
}

variable "repository_name" {
  description = "The name of the repository in which we're operating"
  type        = string
}

variable "service" {
  default     = "forgerock"
  description = "The service name to be used when creating AWS resources"
  type        = string
}

variable "ssl_policy" {
  default     = "ELBSecurityPolicy-TLS13-1-0-2021-06"
  description = "The SSL policy version to be used on the ALB"
  type        = string
}

variable "team" {
  description = "The team responsible for administering the instance"
  type        = string
}

variable "user_data_merge_strategy" {
  default     = "list(append)+dict(recurse_array)+str()"
  description = "Merge strategy to apply to user-data sections for cloud-init"
  type        = string
}
