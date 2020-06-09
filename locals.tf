locals {
  name_tmpl            = format("%s%s-%s", var.cluster_prefix, var.cluster_name, "%s")
  debug_path           = var.debug_path != "" ? var.debug_path : "${path.module}/.debug"
  internal_domain_tmpl = format("%s.%s", var.node_name_tmpl, var.internal_zone)
  internal_url_tmpl    = "https://${local.internal_domain_tmpl}:%d"
  ca_ssh_public_keys   = length(var.ca_ssh_public_keys) == 0 ? false : true
  ca_tls_public_keys   = length(var.ca_tls_public_keys) == 0 ? false : true
  ssh_authorized_keys  = length(var.ssh_authorized_keys) == 0 ? false : true

  tags = merge({
    Description = var.cluster_description
    ManagedBy   = "Terraform"
    Terraform   = true
    Project     = var.cluster_name
    Environment = "stage"
    Service     = "Vault-HA"
    Name        = format("%s%s", var.cluster_prefix, var.cluster_name)
  }, var.tags)

  alb = {
   id = aws_lb.cluster.id
   arn = aws_lb.cluster.arn
   arn_suffix = aws_lb.cluster.arn_suffix
   dns_name = aws_lb.cluster.dns_name
   zone_id = aws_lb.cluster.zone_id
  }

  cluster_url = format("%s://%s:%d",
    var.certificate_arn != "" ? "https" : "http",
    var.cluster_domain != "" ? var.cluster_domain : aws_lb.cluster.dns_name,
    var.cluster_port
  )

  seal_transit = {
    seal = {
      transit = var.seal_transit
    }
  }

  seal_awskms = {
    seal = {
      awskms = var.seal_awskms
    }
  }

  autounseal = {
    seal = {
      awskms = {
        kms_key_id = var.autounseal ? aws_kms_key.autounseal[0].id : ""
      }
    }
  }
}
