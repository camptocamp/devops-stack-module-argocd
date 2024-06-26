
locals {
  argocd_version                  = yamldecode(file("${path.module}/chart-version.yaml")).appVersion
  argocd_hostname_withclustername = format("argocd.%s.%s", trimprefix("${var.subdomain}.${var.cluster_name}", "."), var.base_domain)
  argocd_hostname                 = format("argocd.%s", trimprefix("${var.subdomain}.${var.base_domain}", "."))

  jwt_tokens = {
    for account in var.extra_accounts : account => {
      jti = random_uuid.jti[account].result
      iat = time_static.iat[account].unix
      iss = "argocd"
      nbf = time_static.iat[account].unix
      sub = account
    }
  }

  extra_accounts_tokens = { for account in var.extra_accounts : format("accounts.%s.tokens", account) => replace(jsonencode([
    {
      id  = random_uuid.jti[account].result
      iat = time_static.iat[account].unix
    }
  ]), "\\\"", "\"") }

  extra_objects = [
    {
      apiVersion = "v1"
      kind       = "ConfigMap"
      metadata = {
        name = "kustomized-helm-cm"
      }
      data = {
        "plugin.yaml" = <<-EOT
          apiVersion: argoproj.io/v1alpha1
          kind: ConfigManagementPlugin
          metadata:
            name: kustomized-helm
          spec:
            init:
              command: ["/bin/sh", "-c"]
              args: ["helm dependency build || true"]
            generate:
              command: ["/bin/sh", "-c"]
              args: ["echo \"$ARGOCD_ENV_HELM_VALUES\" | helm template . --name-template $ARGOCD_APP_NAME --namespace $ARGOCD_APP_NAMESPACE $ARGOCD_ENV_HELM_ARGS -f - --include-crds > all.yaml && kustomize build"]
        EOT
      }
    }
  ]

  repo_server_extra_containers = [
    {
      name    = "kustomized-helm-cmp"
      command = ["/var/run/argocd/argocd-cmp-server"]
      # Note: Argo CD official image ships Helm and Kustomize. No need to build a custom image to use "kustomized-helm" plugin.
      image = "quay.io/argoproj/argocd:${local.argocd_version}"
      args  = ["--loglevel=warn"]
      securityContext = {
        runAsNonRoot = true
        runAsUser    = 999
      }
      volumeMounts = [
        {
          mountPath = "/var/run/argocd"
          name      = "var-files"
        },
        {
          mountPath = "/home/argocd/cmp-server/plugins"
          name      = "plugins"
        },
        {
          mountPath = "/home/argocd/cmp-server/config/plugin.yaml"
          subPath   = "plugin.yaml"
          name      = "kustomized-helm-cm"
        },
        {
          mountPath = "/tmp"
          name      = "kustomized-helm-cmp-tmp"
        }
      ]
      # The extra containers of the repo_server pod must have resource requests/limits in order to allow this component
      # to autoscale properly.
      resources = {
        requests = { for k, v in var.resources.kustomized_helm_cmp.requests : k => v if v != null }
        limits   = { for k, v in var.resources.kustomized_helm_cmp.limits : k => v if v != null }
      }
    },
    {
      name    = "helmfile-cmp"
      command = ["/var/run/argocd/argocd-cmp-server"]
      image   = "ghcr.io/camptocamp/docker-argocd-cmp-helmfile:${var.helmfile_cmp_version}"
      args    = ["--loglevel=warn"]
      env     = var.helmfile_cmp_env_variables
      securityContext = {
        runAsNonRoot = true
        runAsUser    = 999
      }
      terminationMessagePath   = "/dev/termination-log"
      terminationMessagePolicy = "File"
      volumeMounts = [
        {
          mountPath = "/var/run/argocd"
          name      = "var-files"
        },
        {
          mountPath = "/home/argocd/cmp-server/plugins"
          name      = "plugins"
        },
        {
          mountPath = "/tmp"
          name      = "helmfile-cmp-tmp"
        }
      ]
      # The extra containers of the repo_server pod must have resource requests/limits in order to allow this component
      # to autoscale properly.
      resources = {
        requests = { for k, v in var.resources.helmfile_cmp.requests : k => v if v != null }
        limits   = { for k, v in var.resources.helmfile_cmp.limits : k => v if v != null }
      }
    }
  ]

  repo_server_volumes = [
    {
      configMap = {
        name = "kustomized-helm-cm"
      }
      name = "kustomized-helm-cm"
    },
    {
      name     = "helmfile-cmp-tmp"
      emptyDir = {}
    },
    {
      name     = "kustomized-helm-cmp-tmp"
      emptyDir = {}
    }
  ]

  repo_server_service_account_annotations = merge(
    var.repo_server_iam_role_arn != null ? { "eks.amazonaws.com/role-arn" = var.repo_server_iam_role_arn } : {},
    var.repo_server_azure_workload_identity_clientid != null ? { "azure.workload.identity/client-id" = var.repo_server_azure_workload_identity_clientid } : {}
  )

  repo_server_pod_labels = merge(
    var.repo_server_azure_workload_identity_clientid != null ? { "azure.workload.identity/use" : "true" } : {},
    var.repo_server_aadpodidbinding != null ? { "aadpodidbinding" : var.repo_server_aadpodidbinding } : {}
  )

  helm_values = [{
    argo-cd = {
      global = {
        domain = local.argocd_hostname
      }
      configs = merge(length(var.repositories) > 0 ? {
        repositories = var.repositories
        } : null, {
        cm = merge({ for account in var.extra_accounts : format("accounts.%s", account) => "apiKey" }, {
          "url"                           = "https://${local.argocd_hostname_withclustername}"
          "accounts.pipeline"             = "apiKey"
          "admin.enabled"                 = var.admin_enabled
          "exec.enabled"                  = var.exec_enabled
          "oidc.config"                   = <<-EOT
            ${yamlencode(merge(var.oidc, { clientSecret = "$oidc.default.clientSecret" }))}
          EOT
          "oidc.tls.insecure.skip.verify" = var.cluster_issuer != "letsencrypt-prod"
          "resource.customizations"       = <<-EOT
            argoproj.io/Application: # https://argo-cd.readthedocs.io/en/stable/operator-manual/health/#argocd-app
              health.lua: |
                hs = {}
                hs.status = "Progressing"
                hs.message = ""
                if obj.status ~= nil then
                  if obj.status.health ~= nil then
                    hs.status = obj.status.health.status
                    if obj.status.health.message ~= nil then
                      hs.message = obj.status.health.message
                    end
                  end
                end
                return hs
            networking.k8s.io/Ingress: # https://argo-cd.readthedocs.io/en/stable/faq/#why-is-my-application-stuck-in-progressing-state
              health.lua: |
                hs = {}
                hs.status = "Healthy"
                return hs
          EOT
        })
        params = {
          "server.insecure" = true # We terminate the SSL connection at the Traefik Ingress Controller
        }
        ssh = {
          knownHosts = var.ssh_known_hosts
        }
        rbac = {
          scopes           = var.rbac.scopes
          "policy.default" = var.rbac.policy_default
          "policy.csv"     = var.rbac.policy_csv
        }
        secret = {
          extra = merge({
            "accounts.pipeline.tokens"  = "${replace(var.accounts_pipeline_tokens, "\\\"", "\"")}"
            "server.secretkey"          = "${replace(var.server_secretkey, "\\\"", "\"")}"
            "oidc.default.clientSecret" = "${replace(var.oidc.clientSecret, "\\\"", "\"")}"
          }, local.extra_accounts_tokens)
        }
      })
      applicationSet = {
        replicas = var.high_availability.enabled ? var.high_availability.application_set.replicas : null
        resources = {
          requests = { for k, v in var.resources.application_set.requests : k => v if v != null }
          limits   = { for k, v in var.resources.application_set.limits : k => v if v != null }
        }
      }
      controller = {
        replicas = var.high_availability.enabled ? var.high_availability.controller.replicas : null
        resources = {
          requests = { for k, v in var.resources.controller.requests : k => v if v != null }
          limits   = { for k, v in var.resources.controller.limits : k => v if v != null }
        }
        metrics = {
          enabled = true
          serviceMonitor = {
            enabled = true
          }
        }
      }
      dex = {
        enabled = false
      }
      repoServer = {
        replicas = var.high_availability.enabled && !var.high_availability.repo_server.autoscaling.enabled ? var.high_availability.server.replicas : null
        autoscaling = var.high_availability.repo_server.autoscaling.enabled ? {
          enabled     = true
          minReplicas = var.high_availability.repo_server.autoscaling.min_replicas
          maxReplicas = var.high_availability.repo_server.autoscaling.max_replicas
        } : null
        resources = {
          requests = { for k, v in var.resources.repo_server.requests : k => v if v != null }
          limits   = { for k, v in var.resources.repo_server.limits : k => v if v != null }
        }
        metrics = {
          enabled = true
          serviceMonitor = {
            enabled = true
          }
        }
        volumes         = local.repo_server_volumes
        extraContainers = local.repo_server_extra_containers
        podLabels       = local.repo_server_pod_labels
        serviceAccount = {
          annotations = local.repo_server_service_account_annotations
        }
      }
      extraObjects = local.extra_objects
      server = {
        replicas = var.high_availability.enabled && !var.high_availability.server.autoscaling.enabled ? var.high_availability.server.replicas : null
        autoscaling = var.high_availability.server.autoscaling.enabled ? {
          enabled     = true
          minReplicas = var.high_availability.server.autoscaling.min_replicas
          maxReplicas = var.high_availability.server.autoscaling.max_replicas
        } : null
        resources = {
          requests = { for k, v in var.resources.server.requests : k => v if v != null }
          limits   = { for k, v in var.resources.server.limits : k => v if v != null }
        }
        ingress = {
          enabled = true
          annotations = {
            "cert-manager.io/cluster-issuer"                   = "${var.cluster_issuer}"
            "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure"
            "traefik.ingress.kubernetes.io/router.tls"         = "true"
          }
          hostname = local.argocd_hostname_withclustername
          extraHosts = [
            {
              name = local.argocd_hostname
              path = "/"
            }
          ]
          extraTls = [
            {
              hosts = [
                local.argocd_hostname,
                local.argocd_hostname_withclustername
              ]
              secretName = "argocd-tls"
            }
          ]
        }
        metrics = {
          enabled = true
          serviceMonitor = {
            enabled = true
          }
        }
      }
      notifications = {
        resources = {
          requests = { for k, v in var.resources.notifications.requests : k => v if v != null }
          limits   = { for k, v in var.resources.notifications.limits : k => v if v != null }
        }
      }
      # When the Redis HA is enabled, the default Redis chart is not used, so we change the value to null.
      redis = !var.high_availability.enabled ? {
        resources = {
          requests = { for k, v in var.resources.redis.requests : k => v if v != null }
          limits   = { for k, v in var.resources.redis.limits : k => v if v != null }
        }
      } : null
      redis-ha = var.high_availability.enabled ? {
        enabled = true
        redis = {
          resources = {
            requests = { for k, v in var.resources.redis.requests : k => v if v != null }
            limits   = { for k, v in var.resources.redis.limits : k => v if v != null }
          }
        }
        } : {
        enabled = false
        redis   = null
      }
    }
  }]
}
