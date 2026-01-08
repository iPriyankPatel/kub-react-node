output "frontend_service_name" {
  value = kubernetes_service_v1.frontend_service.metadata[0].name
}

output "auth_service_name" {
  value = kubernetes_service_v1.auth_service.metadata[0].name
}

output "tasks_service_name" {
  value = kubernetes_service_v1.tasks_service.metadata[0].name
}

output "users_service_name" {
  value = kubernetes_service_v1.users_service.metadata[0].name
}
