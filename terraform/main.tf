provider "kubernetes" {
  config_path = "~/.kube/config" # points to your Minikube/kind kubeconfig
}

# resource "kubernetes_namespace_v1" "myapp" {
#   metadata {
#     name = "myapp"
#   }
# }


## users k8 deployment
resource "kubernetes_deployment_v1" "users_backend" {
  metadata {
    name      = "users-deployment"
    # namespace = kubernetes_namespace_v1.myapp.metadata[0].name
    labels    = { app = "users" }
  }

  spec {
    replicas = 1

    selector {
      match_labels = { app = "users" }
    }

    template {
      metadata {
        labels = { app = "users" }
      }

      spec {
        container {
          name              = "users"
          image             = "pdocklab/kub-kind-users:latest"
          image_pull_policy = "IfNotPresent"

          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

## users k8 service
resource "kubernetes_service_v1" "users_service" {
  metadata {
    name      = "users-service"
    # namespace = kubernetes_namespace_v1.myapp.metadata[0].name
  }

  spec {
    selector = { app = "users" }

    port {
      port        = 8080
      target_port = 8080
    }

    # type = "ClusterIP"
    type = "NodePort" # so you can access from host
  }
}


## tasks k8s deployment
resource "kubernetes_deployment_v1" "tasks" {
  metadata {
    name      = "tasks-deployment"
    # namespace = kubernetes_namespace_v1.myapp.metadata[0].name
    labels    = { app = "tasks" }
  }

  spec {
    replicas = 1

    selector {
      match_labels = { app = "tasks" }
    }

    template {
      metadata {
        labels = { app = "tasks" }
      }

      spec {
        container {
          name              = "tasks"
          image             = "pdocklab/kub-kind-tasks:latest"
          image_pull_policy = "IfNotPresent"

          port {
            container_port = 8000
          }
        }
      }
    }
  }
}

## tasks k8 service 
resource "kubernetes_service_v1" "tasks_service" {
  metadata {
    name      = "tasks-service"
    # namespace = kubernetes_namespace_v1.myapp.metadata[0].name
  }

  spec {
    selector = { app = "tasks" }

    port {
      port        = 8000
      target_port = 8000
    }

    # type = "ClusterIP"
    type = "NodePort" # so you can access from host
  }
}


## frontend k8  deployment
resource "kubernetes_deployment_v1" "frontend" {
  metadata {
    name      = "frontend-deployment"
    # namespace = kubernetes_namespace_v1.myapp.metadata[0].name
    labels    = { app = "frontend" }
  }

  spec {
    replicas = 1

    selector {
      match_labels = { app = "frontend" }
    }

    template {
      metadata {
        labels = { app = "frontend" }
      }

      spec {
        container {
          name  = "frontend"
          image = "pdocklab/kub-kind-frontend:latest"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

## frontend k8 service
resource "kubernetes_service_v1" "frontend_service" {
  metadata {
    name      = "frontend-service"
    # namespace = kubernetes_namespace_v1.myapp.metadata[0].name
  }

  spec {
    selector = { app = "frontend" }

    port {
      port        = 80
      target_port = 80
    }

    type = "NodePort" # so you can access from host
  }
}


## auth k8  deployment
resource "kubernetes_deployment_v1" "auth" {
  metadata {
    name      = "auth-deployment"
    # namespace = kubernetes_namespace_v1.myapp.metadata[0].name
    labels    = { app = "auth" }
  }

  spec {
    replicas = 1

    selector {
      match_labels = { app = "auth" }
    }

    template {
      metadata {
        labels = { app = "auth" }
      }

      spec {
        container {
          name  = "auth"
          image = "pdocklab/kub-kind-auth:latest"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

## auth k8 service
resource "kubernetes_service_v1" "auth_service" {
  metadata {
    name      = "auth-service"
    # namespace = kubernetes_namespace_v1.myapp.metadata[0].name
  }

  spec {
    selector = { app = "auth" }

    port {
      port        = 80
      target_port = 80
    }

    # type = "NodePort" # so you can access from host
    type = "ClusterIP"
  }
}


resource "kubernetes_ingress_v1" "myapp_ingress" {
  metadata {
    name      = "myapp-ingress"
    # namespace = kubernetes_namespace_v1.myapp.metadata[0].name
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }

  spec {
    rule {
      # host = "myapp.local"
      host = "default.local"

      http {
        path {
          path = "/"
          
          backend {
            service {
              name = kubernetes_service_v1.frontend_service.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }

        path {
          path = "/"
          backend {
            service {
              name = kubernetes_service_v1.auth_service.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }

        path {
          path = "/users"
          backend {
            service {
              name = kubernetes_service_v1.users_service.metadata[0].name
              port {
                number = 8080
              }
            }
          }
        }

        path {
          path = "/tasks"
          backend {
            service {
              name = kubernetes_service_v1.tasks_service.metadata[0].name
              port {
                number = 8000
              }
            }
          }
        }

      }
    }
  }
}
