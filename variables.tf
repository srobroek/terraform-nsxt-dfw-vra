variable product {
  type = string
}
variable environment {
  type = string
}
variable provider_groups {
  type = object({
    provides_all_https = object()
    provides_all_ssh = object()
    provides_lb_https = object()
  })

}
