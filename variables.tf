variable "profile_path" {
  description = "Path to configuration profile relative to the current working directory"
  type        = string

  validation {
    condition     = fileexists(var.profile_path)
    error_message = "This file does not exist"
  }
}

variable "profile_name" {
  description = "Name of the configuration profile. This will be used to create the static exclusion group for the profile"
  type        = string
}

variable "description" {
  description = "Description of this profile."
  type        = string
  default     = null
}

variable "category_id" {
  description = "Category ID"
  type        = string
  default     = "-1"
}

variable "distribution_method" {
  description = "How to distribute the profile"
  type        = string
  default     = "Install Automatically"
}

variable "user_removable" {
  description = "Is the profile user removable"
  type        = bool
  default     = false
}

variable "redeploy_on_update" {
  description = "Should the profile be redeployed on update"
  type        = string
  default     = "Newly Assigned"
}

variable "level" {
  description = "How to distribute the profile"
  type        = string
  default     = "System"

  validation {
    condition     = contains(["System", "User"], var.level)
    error_message = "This must be one of ('System', or 'User')"
  }
}

variable "payload_validate" {
  description = "Should the payload be validated"
  type        = bool
  default     = true
}

variable "all_computers" {
  description = "Scope to all computers"
  type        = bool
  default     = false
}

variable "all_jss_users" {
  description = "Scope to all users"
  type        = bool
  default     = false
}

variable "computer_group_ids" {
  description = "IDs of the computer groups to scope this profile to"
  type        = list(number)
  default     = []
}

variable "source_repo" {
  description = "URL of the source repository"
  type        = string
  default     = null
}

variable "profile_template_vars" {
  description = "Used to determine if the payload should be templated"
  type        = map(string)
  default     = {}
}

variable "resource_suffix" {
  description = "Adds a suffix to the end of resource names (Default: (tf))"
  type        = string
  default     = "(tf)"
}

variable "recreate_profile_on_update" {
  description = "Should the profile be recreated on updates to the Configuration Profile"
  type        = bool
  default     = false
}

variable "directory_service_usergroup_ids_limitations" {
  description = "A list of directory service group IDs for limitations"
  type        = list(number)
  default     = []
}

variable "directory_service_usergroup_ids_exclusions" {
  description = "A list of directory service group IDs for exclusions"
  type        = list(number)
  default     = []
}
