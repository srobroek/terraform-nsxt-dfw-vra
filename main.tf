locals {
  services = [
      "HTTPS", 
      "SSH"
    ]

  }
  

##Define new services
resource "nsxt_policy_service" "vra_healthmonitor" {
  description  = ""
  display_name = "vra_healthmonitor"

  l4_port_set_entry {
    display_name      = "TCP8008"
    description       = ""
    protocol          = "TCP"
    destination_ports = ["8008"]
  }
}

resource "nsxt_policy_service" "vra_cluster" {
  description  = ""
  display_name = "vra_cluster"

  l4_port_set_entry {
    display_name      = "UDP"
    description       = ""
    protocol          = "UDP"
    destination_ports = ["500", "4500","8285",]
  }
  l4_port_set_entry {
    display_name      = "UDP"
    description       = ""
    protocol          = "UDP"
    destination_ports = ["2379","2380","6443","10250",]
  }
}


##Source existing services

data "nsxt_policy_service" "service" {

  for_each = toset(local.services)
  display_name = each.value
}



## create provider groups

resource "nsxt_policy_group" "provides-all-ssh" {

  display_name = "provides.ssh.all.${var.product}.${var.environment}"
  criteria {
    path_expression {
      member_paths = [var.groups.vra.path]
    }
  }
}

resource "nsxt_policy_group" "consumes-all-ssh" {

  display_name = "consumes.ssh.all.${var.product}.${var.environment}"
  criteria {
    path_expression {
      member_paths = []
      # for key, value in var.lb_groups: (data.nsxt_policy_group.lb_groups[key]).path
      #for p in var.provider_groups.provides_all_https: p.path
    }
  }
}

resource "nsxt_policy_group" "provides-all-https" {

  display_name = "provides.https.all.${var.product}.${var.environment}"
  criteria {
    path_expression {
      member_paths = [ ]
    }
  }
}

resource "nsxt_policy_group" "consumes-all-https" {

  display_name = "consumes.https.all.${var.product}.${var.environment}"
  criteria {
    path_expression {
      member_paths = []
    }
  }
}

resource "nsxt_policy_group" "provides-lb-https" {

  display_name = "provides.https.lb.${var.product}.${var.environment}"
  criteria {
    path_expression {
      member_paths = [ ]
    }
  }
}

resource "nsxt_policy_group" "consumes-lb-https" {

  display_name = "consumes.https.lb.${var.product}.${var.environment}"
  criteria {
    path_expression {
      member_paths = []
    }
  }
}

resource "nsxt_policy_group" "provides-all-icc" {

  display_name = "provides.icc.all.${var.product}.${var.environment}"
  criteria {
    path_expression {
      member_paths = [ ]
    }
  }
}

resource "nsxt_policy_group" "consumes-all-icc" {

  display_name = "consumes.icc.all.${var.product}.${var.environment}"
  criteria {
    path_expression {
      member_paths = [ ]
    }
  }
}









### firewall rules

resource "nsxt_policy_security_policy" "vra" {
  display_name = "vRealize Automation"
  description  = ""
  category     = "Application"
  locked       = false
  stateful     = true
  tcp_strict   = false

  rule {
    display_name       = "vRA: ssh to appliances"

    source_groups      = [nsxt_policy_group.consumes-all-ssh.path]
    destination_groups = [nsxt_policy_group.provides-all-ssh.path]
    action             = "ALLOW"
    services         = [data.nsxt_policy_service.service["SSH"].path]

  }

  rule {
    display_name       = "vRA: https to appliances"

    source_groups      = [nsxt_policy_group.consumes-all-https.path]
    destination_groups = [nsxt_policy_group.provides-all-https.path]
    action             = "ALLOW"
    services         = [data.nsxt_policy_service.service["HTTPS"].path]

  }

    rule {
    display_name       = "vRA: https to loadbalancer"

    source_groups      = [nsxt_policy_group.consumes-lb-https.path]
    destination_groups = [nsxt_policy_group.provides-lb-https.path]
    action             = "ALLOW"
    services         = [data.nsxt_policy_service.service["HTTPS"].path]

  }

  rule {
    display_name       = "vRA: health monitor"

    source_groups      = [nsxt_policy_group.consumes-all-icc.path]
    destination_groups = [nsxt_policy_group.provides-all-icc.path]
    action             = "ALLOW"
    services         = [nsxt_policy_service.vra_healthmonitor.path]

  }

    rule {
    display_name       = "vRA: inter cluster communication"

    source_groups      = [nsxt_policy_group.consumes-all-icc.path]
    destination_groups = [nsxt_policy_group.provides-all-icc.path]
    action             = "ALLOW"
    services         = [nsxt_policy_service.vra_cluster.path]

  }

}
