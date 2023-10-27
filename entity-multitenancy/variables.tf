# variables.tf

variable "vault_addr" {
  default     = "http://127.0.0.1:18200"
  description = "Vault Cluster Address"
  type        = string
}

#variable "vault_token" {
#  default     = ""
#  description = "Vault Token"
#  type        = string
#}

variable "vault_namespace_parent" {
  default     = "education"
  description = "Parent Namespace"
  type        = string
}

/* variable "vault_namespace_child" {
  type = set(string)
  default = [
    "education training", "education/training/"
    "education certification", "education/certification/"
  ]
} */

/* variable "vault_namespace_children" {
  type = map(string)
  default = {
    "education training"      = "education/training/"
    "education certification" = "education/certification/"
  }
} */

variable "vault_namespace_children" {
  type = map(object({
    name = string,
    path = string
  }))
  default = {
    "education training" = {
      name = "education training"
      path = "training"
    }
    "education certification" = {
      name = "education certification"
      path = "certification"
    }
  }
}




