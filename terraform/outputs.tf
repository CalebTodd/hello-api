output docker_tag {
  description = "Run this command to tag your local container image with the correct ECR information"
  value       = "docker tag $IMAGE_HASH ${aws_ecr_repository.app.repository_url}:${var.image_tag}"
}

output docker_push {
  description = "Run this command to push your local container image to ECR"
  value       = "docker push ${aws_ecr_repository.app.repository_url}:${var.image_tag}"
}

output hello {
  description = "This is the hello endpoint on the API using the public route"
  value       = "curl -s http://${module.app.alb_dns_name}:${var.app_port}"
}

