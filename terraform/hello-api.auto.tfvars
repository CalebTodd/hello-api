namespace = "ctodd"
app_name  = "hello-api"
tags_common = {
  managed_resource = "true"
  src_url          = "github.com/calebtodd/hello-api"
}
vpc_cidr           = "10.133.0.0/20"
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
image_tag          = "latest"
db_user            = "api_user"
db_name            = "hello"
db_host            = "localhost"
app_port           = 8080
// passed in via user input
# db_password =