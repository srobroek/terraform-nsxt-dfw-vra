variable product {
  type = string
}
variable environment {
  type = string
}
variable provider_groups {
  type = object({
    provides_all_https = list(object())
    provides_all_ssh = list(object())
    provides_lb_https = list(object())
    provides-all-icc = list(object())
  })

}
