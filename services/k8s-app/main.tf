locals {
  pod_labels = {
    app = var.name
  }
}

terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

resource "kubernetes_deployment" "app" {
  metadata { # used to identify and target that object in API calls
    name = var.name
  }

  spec {
    replicas = var.replicas

    # In Kubernetes, instead of deploying one container at a time, you deploy 
    # Pods, which are groups of containers that are meant to be deployed 
    # together. The template block is where you define the Pod Template
    template {

      # labels are used to identify the Pods that need to be load balanced
      metadata {
        labels = local.pod_labels
      }

      spec {
        container {
          name  = var.name  # container name
          image = var.image # Docker image

          port {
            container_port = var.container_port # container port(s)
          }

          dynamic "env" { # dynamic block
            for_each = var.environment_variables
            content {
              name  = env.key
              value = env.value
            }
          }
        }
      }
    }
    # Selector block tell the kuvernetes deployment what to target
    selector {
      match_labels = local.pod_labels
    }
  }
}

resource "kubernetes_service" "app" {
  metadata { # identify and target that object in API calls
    name = var.name
  }

  spec {
    type = "LoadBalancer" # service tyé
    port {
      port        = 80 # load banacer to route traffic on port 80
      target_port = var.container_port
      protocol    = "TCP"
    }
    selector = local.pod_labels
  }
}