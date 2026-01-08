variable "frontend_image" {
  default = "pdocklab/kub-kind-frontend:latest"
}

variable "auth_image" {
  default = "pdocklab/kub-kind-auth:latest"
}

variable "backend_image" {
  default = "pdocklab/kub-kind-users:latest"
}

variable "tasks_image" {
  default = "pdocklab/kub-kind-tasks:latest"
}

variable "namespace" {
  # default = "myapp"
  default = "default"
}

variable "frontend_port" { default = 80 }
variable "backend_port"  { default = 8080 }
variable "tasks_port"    { default = 8000 }
