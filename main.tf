terraform {
  required_providers {
    jamfpro = {
      source  = "deploymenttheory/jamfpro"
      version = ">= 0.6.0, < 1.0.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.12.0, < 1.0.0"
    }
  }
}

locals {
  repo_path = var.source_repo != null ? "${var.source_repo}/tree/main/${var.profile_path}" : null

  description_updated = "Updated: ${time_static.this.id}"
  description_source  = local.repo_path != null ? "Source: ${local.repo_path}" : ""
  description_info    = var.description != null ? "Info: ${var.description}" : ""

  payloads     = length(var.profile_template_vars) == 0 ? file(var.profile_path) : templatefile(var.profile_path, var.profile_template_vars)
  payloads_md5 = md5(local.payloads)

  resource_suffix = var.resource_suffix != "" ? " ${var.resource_suffix}" : ""

  replace_trigger_input = var.recreate_profile_on_update ? local.payloads_md5 : null
}

resource "terraform_data" "replace_trigger" {
  input = local.replace_trigger_input
}

resource "time_static" "this" {
  triggers = {
    profile_path = var.profile_path
    profile_hash = local.payloads_md5
  }
}

resource "jamfpro_static_computer_group" "static_exclusions" {
  name = "${var.profile_name} - Static Exclusions${local.resource_suffix}"

  lifecycle {
    ignore_changes = [assigned_computer_ids]
  }
}

resource "jamfpro_macos_configuration_profile_plist" "this" {
  name = "${var.profile_name}${local.resource_suffix}"

  payloads    = local.payloads
  category_id = var.category_id
  description = trimspace(<<-EOT
    ${local.description_updated}
    ${local.description_source}
    ${local.description_info}
  EOT
  )
  distribution_method = var.distribution_method
  user_removable      = var.user_removable
  redeploy_on_update  = var.redeploy_on_update
  level               = var.level
  payload_validate    = var.payload_validate

  scope {
    all_computers      = var.all_computers
    all_jss_users      = var.all_jss_users
    computer_group_ids = sort(var.computer_group_ids)

    exclusions {
      computer_group_ids                   = sort([jamfpro_static_computer_group.static_exclusions.id])
    }
  }

  lifecycle {
    create_before_destroy = false
    replace_triggered_by  = [terraform_data.replace_trigger]    

    ignore_changes = [
      scope[0].limitations[0].directory_service_usergroup_ids,
      scope[0].exclusions[0].directory_service_usergroup_ids,
    ]
  }
}
