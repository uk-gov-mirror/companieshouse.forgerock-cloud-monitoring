###
# Data lookups
###
data "aws_vpc" "vpc" {
  tags = {
    Name = var.vpc_name
  }
}

data "aws_subnet_ids" "subnets" {
  vpc_id = data.aws_vpc.vpc.id
  filter {
    name   = "tag:Name"
    values = ["*-applications-*"]
  }
}

###
# Modules
###
module "cloudwatch" {
  source            = "./modules/cloudwatch"
  region            = var.region
  environment       = var.environment
  service_name      = var.service_name
  retention_in_days = var.log_retention_in_days
  tags              = local.common_tags
}

module "alerting" {
  source                 = "./modules/sns"
  service_name           = var.service_name
  alerting_email_address = var.alerting_email_address
  tags                   = local.common_tags
}

module "ecs" {
  source       = "./modules/ecs"
  service_name = var.service_name
  vpc_id       = data.aws_vpc.vpc.id
  tags         = local.common_tags
}

module "idm_logging" {
  source                     = "./modules/ecs-task"
  depends_on                 = [module.cloudwatch]
  region                     = var.region
  task_name                  = "idm_logging"
  subnet_ids                 = data.aws_subnet_ids.subnets.ids
  ecs_cluster_id             = module.ecs.cluster_id
  ecs_task_role_arn          = module.ecs.task_role_arn
  ecs_task_security_group_id = module.ecs.task_security_group_id
  container_image_version    = "logging-${var.container_image_version}"
  ecr_url                    = var.ecr_url
  task_cpu                   = var.task_cpu
  task_memory                = var.task_memory
  fidc_url                   = var.fidc_url
  fidc_api_key_id            = var.fidc_api_key_id
  fidc_api_key_secret        = var.fidc_api_key_secret
  service_name               = var.service_name
  log_prefix                 = "idm_logging"
  tags                       = local.common_tags
  log_source                 = "idm"
  log_frequency              = 10
  restart_frequency_schedule = "cron(0 2 * * ? *)"
}

module "am_logging" {
  source                     = "./modules/ecs-task"
  depends_on                 = [module.cloudwatch]
  region                     = var.region
  task_name                  = "am_logging"
  subnet_ids                 = data.aws_subnet_ids.subnets.ids
  ecs_cluster_id             = module.ecs.cluster_id
  ecs_task_role_arn          = module.ecs.task_role_arn
  ecs_task_security_group_id = module.ecs.task_security_group_id
  container_image_version    = "logging-${var.container_image_version}"
  ecr_url                    = var.ecr_url
  task_cpu                   = var.task_cpu
  task_memory                = var.task_memory
  fidc_url                   = var.fidc_url
  fidc_api_key_id            = var.fidc_api_key_id
  fidc_api_key_secret        = var.fidc_api_key_secret
  service_name               = var.service_name
  log_prefix                 = "am_logging"
  tags                       = local.common_tags
  log_source                 = "am"
  log_frequency              = 2
  restart_frequency_schedule = "cron(0 2 * * ? *)"
}

module "rcs_monitoring" {
  source                   = "./modules/cloudwatch-canary"
  region                   = var.region
  environment              = var.environment
  service_name             = var.service_name
  canary_name              = "fr-rcs"
  release_version          = var.container_image_version
  handler                  = "index.handler"
  runtime_version          = "syn-nodejs-puppeteer-9.0"
  release_bucket           = var.release_bucket
  source_code_path         = "${path.module}/scripts/rcs-monitoring"
  artifact_bucket          = module.cloudwatch.canary_artifact_bucket
  role_arn                 = module.cloudwatch.canary_role_arn
  health_check_rate        = var.health_check_rate
  fidc_url                 = var.fidc_url
  fidc_user                = var.fidc_user
  fidc_password            = var.fidc_password
  fidc_admin_client        = var.fidc_admin_client
  fidc_admin_client_secret = var.fidc_admin_client_secret
  fidc_monitored_component = var.fidc_connector_group
  recon_duration           = var.recon_duration
  cancel_recon_after       = var.cancel_recon_after
  sns_topic_arn            = module.alerting.sns_topic_arn
  tags                     = local.common_tags
}

module "mapping_chscompany" {
  source                   = "./modules/cloudwatch-canary"
  region                   = var.region
  environment              = var.environment
  service_name             = var.service_name
  canary_name              = "mapping-chscompany"
  release_version          = var.container_image_version
  source_code_path         = "${path.module}/scripts/mappings-monitoring"
  handler                  = "index.handler"
  runtime_version          = "syn-nodejs-puppeteer-9.0"
  release_bucket           = var.release_bucket
  artifact_bucket          = module.cloudwatch.canary_artifact_bucket
  role_arn                 = module.cloudwatch.canary_role_arn
  health_check_rate        = var.health_check_rate
  fidc_url                 = var.fidc_url
  fidc_user                = var.fidc_user
  fidc_password            = var.fidc_password
  fidc_admin_client        = var.fidc_admin_client
  fidc_admin_client_secret = var.fidc_admin_client_secret
  fidc_monitored_component = "chsMongoCompanyProfile_alphaOrg"
  recon_duration           = var.recon_duration
  cancel_recon_after       = var.cancel_recon_after
  sns_topic_arn            = module.alerting.sns_topic_arn
  tags                     = local.common_tags
}

module "mapping_wfauthcode" {
  source                   = "./modules/cloudwatch-canary"
  region                   = var.region
  environment              = var.environment
  service_name             = var.service_name
  canary_name              = "mapping-wfauthcode"
  release_version          = var.container_image_version
  source_code_path         = "${path.module}/scripts/mappings-monitoring"
  handler                  = "index.handler"
  runtime_version          = "syn-nodejs-puppeteer-9.0"
  release_bucket           = var.release_bucket
  artifact_bucket          = module.cloudwatch.canary_artifact_bucket
  role_arn                 = module.cloudwatch.canary_role_arn
  health_check_rate        = var.health_check_rate
  fidc_url                 = var.fidc_url
  fidc_user                = var.fidc_user
  fidc_password            = var.fidc_password
  fidc_admin_client        = var.fidc_admin_client
  fidc_admin_client_secret = var.fidc_admin_client_secret
  fidc_monitored_component = "webfilingAuthCode_alphaOrg"
  recon_duration           = var.recon_duration
  cancel_recon_after       = var.cancel_recon_after
  sns_topic_arn            = module.alerting.sns_topic_arn
  tags                     = local.common_tags
}

module "mapping_wfuser" {
  source                   = "./modules/cloudwatch-canary"
  region                   = var.region
  environment              = var.environment
  service_name             = var.service_name
  canary_name              = "mapping-wfuser"
  release_version          = var.container_image_version
  source_code_path         = "${path.module}/scripts/mappings-monitoring"
  handler                  = "index.handler"
  runtime_version          = "syn-nodejs-puppeteer-9.0"
  release_bucket           = var.release_bucket
  artifact_bucket          = module.cloudwatch.canary_artifact_bucket
  role_arn                 = module.cloudwatch.canary_role_arn
  health_check_rate        = var.health_check_rate
  fidc_url                 = var.fidc_url
  fidc_user                = var.fidc_user
  fidc_password            = var.fidc_password
  fidc_admin_client        = var.fidc_admin_client
  fidc_admin_client_secret = var.fidc_admin_client_secret
  fidc_monitored_component = "webfilingUser_alphaUser"
  recon_duration           = var.recon_duration
  cancel_recon_after       = var.cancel_recon_after
  sns_topic_arn            = module.alerting.sns_topic_arn
  tags                     = local.common_tags
}

module "connector_chscompany" {
  source                   = "./modules/cloudwatch-canary"
  region                   = var.region
  environment              = var.environment
  service_name             = var.service_name
  canary_name              = "connector-chscompany"
  release_version          = var.container_image_version
  source_code_path         = "${path.module}/scripts/mappings-monitoring"
  handler                  = "index.handler"
  runtime_version          = "syn-nodejs-puppeteer-9.0"
  release_bucket           = var.release_bucket
  artifact_bucket          = module.cloudwatch.canary_artifact_bucket
  role_arn                 = module.cloudwatch.canary_role_arn
  health_check_rate        = var.health_check_rate
  fidc_url                 = var.fidc_url
  fidc_user                = var.fidc_user
  fidc_password            = var.fidc_password
  fidc_admin_client        = var.fidc_admin_client
  fidc_admin_client_secret = var.fidc_admin_client_secret
  fidc_monitored_component = "CHSCompany"
  recon_duration           = var.recon_duration
  cancel_recon_after       = var.cancel_recon_after
  sns_topic_arn            = module.alerting.sns_topic_arn
  tags                     = local.common_tags
}

module "connector_wfauthcode" {
  source                   = "./modules/cloudwatch-canary"
  region                   = var.region
  environment              = var.environment
  service_name             = var.service_name
  canary_name              = "connector-wfauthcode"
  release_version          = var.container_image_version
  source_code_path         = "${path.module}/scripts/mappings-monitoring"
  handler                  = "index.handler"
  runtime_version          = "syn-nodejs-puppeteer-9.0"
  release_bucket           = var.release_bucket
  artifact_bucket          = module.cloudwatch.canary_artifact_bucket
  role_arn                 = module.cloudwatch.canary_role_arn
  health_check_rate        = var.health_check_rate
  fidc_url                 = var.fidc_url
  fidc_user                = var.fidc_user
  fidc_password            = var.fidc_password
  fidc_admin_client        = var.fidc_admin_client
  fidc_admin_client_secret = var.fidc_admin_client_secret
  fidc_monitored_component = "WebfilingAuthCode"
  recon_duration           = var.recon_duration
  cancel_recon_after       = var.cancel_recon_after
  sns_topic_arn            = module.alerting.sns_topic_arn
  tags                     = local.common_tags
}

module "connector_wfuser" {
  source                   = "./modules/cloudwatch-canary"
  region                   = var.region
  environment              = var.environment
  service_name             = var.service_name
  canary_name              = "connector-wfuser"
  release_version          = var.container_image_version
  source_code_path         = "${path.module}/scripts/mappings-monitoring"
  handler                  = "index.handler"
  runtime_version          = "syn-nodejs-puppeteer-9.0"
  release_bucket           = var.release_bucket
  artifact_bucket          = module.cloudwatch.canary_artifact_bucket
  role_arn                 = module.cloudwatch.canary_role_arn
  health_check_rate        = var.health_check_rate
  fidc_url                 = var.fidc_url
  fidc_user                = var.fidc_user
  fidc_password            = var.fidc_password
  fidc_admin_client        = var.fidc_admin_client
  fidc_admin_client_secret = var.fidc_admin_client_secret
  fidc_monitored_component = "WebfilingUser"
  recon_duration           = var.recon_duration
  cancel_recon_after       = var.cancel_recon_after
  sns_topic_arn            = module.alerting.sns_topic_arn
  tags                     = local.common_tags
}

module "duration_chscompany" {
  source                   = "./modules/cloudwatch-canary"
  region                   = var.region
  environment              = var.environment
  service_name             = var.service_name
  canary_name              = "duration-chscompany"
  release_version          = var.container_image_version
  source_code_path         = "${path.module}/scripts/mappings-monitoring"
  handler                  = "index.handler"
  runtime_version          = "syn-nodejs-puppeteer-9.0"
  release_bucket           = var.release_bucket
  artifact_bucket          = module.cloudwatch.canary_artifact_bucket
  role_arn                 = module.cloudwatch.canary_role_arn
  health_check_rate        = var.health_check_rate
  fidc_url                 = var.fidc_url
  fidc_user                = var.fidc_user
  fidc_password            = var.fidc_password
  fidc_admin_client        = var.fidc_admin_client
  fidc_admin_client_secret = var.fidc_admin_client_secret
  fidc_monitored_component = "chsMongoCompanyProfile_alphaOrg"
  recon_duration           = var.recon_duration
  cancel_recon_after       = var.cancel_recon_after
  sns_topic_arn            = module.alerting.sns_topic_arn
  tags                     = local.common_tags
}

module "duration_wfauthcode" {
  source                   = "./modules/cloudwatch-canary"
  region                   = var.region
  environment              = var.environment
  service_name             = var.service_name
  canary_name              = "duration-wfauthcode"
  release_version          = var.container_image_version
  source_code_path         = "${path.module}/scripts/mappings-monitoring"
  handler                  = "index.handler"
  runtime_version          = "syn-nodejs-puppeteer-9.0"
  release_bucket           = var.release_bucket
  artifact_bucket          = module.cloudwatch.canary_artifact_bucket
  role_arn                 = module.cloudwatch.canary_role_arn
  health_check_rate        = var.health_check_rate
  fidc_url                 = var.fidc_url
  fidc_user                = var.fidc_user
  fidc_password            = var.fidc_password
  fidc_admin_client        = var.fidc_admin_client
  fidc_admin_client_secret = var.fidc_admin_client_secret
  fidc_monitored_component = "webfilingAuthCode_alphaOrg"
  recon_duration           = var.recon_duration
  cancel_recon_after       = var.cancel_recon_after
  sns_topic_arn            = module.alerting.sns_topic_arn
  tags                     = local.common_tags
}

module "duration_wfuser" {
  source                   = "./modules/cloudwatch-canary"
  region                   = var.region
  environment              = var.environment
  service_name             = var.service_name
  canary_name              = "duration-wfuser"
  release_version          = var.container_image_version
  source_code_path         = "${path.module}/scripts/mappings-monitoring"
  handler                  = "index.handler"
  runtime_version          = "syn-nodejs-puppeteer-9.0"
  release_bucket           = var.release_bucket
  artifact_bucket          = module.cloudwatch.canary_artifact_bucket
  role_arn                 = module.cloudwatch.canary_role_arn
  health_check_rate        = var.health_check_rate
  fidc_url                 = var.fidc_url
  fidc_user                = var.fidc_user
  fidc_password            = var.fidc_password
  fidc_admin_client        = var.fidc_admin_client
  fidc_admin_client_secret = var.fidc_admin_client_secret
  fidc_monitored_component = "webfilingUser_alphaUser"
  recon_duration           = var.recon_duration
  cancel_recon_after       = var.cancel_recon_after
  sns_topic_arn            = module.alerting.sns_topic_arn
  tags                     = local.common_tags
}

module "cancelRecon" {
  source                   = "./modules/cloudwatch-canary"
  region                   = var.region
  environment              = var.environment
  service_name             = var.service_name
  canary_name              = "fr-cancel-recon-after"
  release_version          = var.container_image_version
  source_code_path         = "${path.module}/scripts/mappings-monitoring"
  handler                  = "index.handler"
  runtime_version          = "syn-nodejs-puppeteer-9.0"
  release_bucket           = var.release_bucket
  artifact_bucket          = module.cloudwatch.canary_artifact_bucket
  role_arn                 = module.cloudwatch.canary_role_arn
  health_check_rate        = var.health_check_rate
  fidc_url                 = var.fidc_url
  fidc_user                = var.fidc_user
  fidc_password            = var.fidc_password
  fidc_admin_client        = var.fidc_admin_client
  fidc_admin_client_secret = var.fidc_admin_client_secret
  fidc_monitored_component = var.fidc_mappings
  recon_duration           = var.recon_duration
  cancel_recon_after       = var.cancel_recon_after
  sns_topic_arn            = module.alerting.sns_topic_arn
  tags                     = local.common_tags
}
