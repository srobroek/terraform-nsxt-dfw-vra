variable product {
  type = string
}
variable environment {
  type = string
}
variable provider_groups {
  type = list(object({
  provides_all_https_all = list(string)
  provides_all_ssh = list(string)
  provides_lb_https = list(string)
  }))
}
