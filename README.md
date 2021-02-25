# HELLO-API

## Environment File

Create a file with this HEREDOC command:

```sh
cat << EOF > .env
PGADMIN_DEFAULT_EMAIL=admin@example.com
PGADMIN_DEFAULT_PASSWORD=mySecretePgAdminUiPwd
DB_HOST=localhost
DB_PASSWORD=mySecreteDbPwd
DB_USER=api_user
DB_NAME=hello
EOF
```

## PG ADMIN

This is optional for the curious DevOps-erator.

Use the `PGADMIN_DEFAULT_EMAIL` / `PGADMIN_DEFAULT_PASSWORD` values to log into the PgAdmin UI at "http://localhost:5050"

Connect a server with the following considerations:

General Tab:

- name the server anything

Connection Tab:

- hostname within Docker Compose is `postgres` (although, you can likely telnet it from your host shell via `telnet localhost 5432`)
- username should be updated to match `DB_USER` from the environment file
- similarly, password should match `DB_PASSWORD`. Feel free to check the box to save it.

## Run

```sh
docker-compose build
docker-compose up -d
...
docker-compose down
```

## Usage

### HELLO

```sh
curl -s http://localhost:8080 | jq
```

### POST USER

This creates a auser in the database with just a simple `first_name` and `last_name` field. Both are required.

```sh
curl -s -X POST http://localhost:8080/api/users -d '{"first_name":"Caleb","last_name":"Todd"}'
```

### GET USER

```sh
curl -s http://localhost:8080/api/users/1 | jq
```

## AWS Deploy

1. Assumes `docker-compose build` has at least been executed. If not, work through the above documentation up until that point. Take note of the image hash. `export ID=<hash>`

2. Prepare your AWS Credentials

    a. Authenticate to AWS CLI. If using a named session, set the `AWS_PROFILE` environment variable appropriately per [the documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html)

    b. Export the `AWS_DEFAULT_REGION` environment variable so that the Terraform AWS Provider will pick up on it.

    c. Get an ECR token. This will allow docker push/pull commands to ECR. [Reference Documentation](https://docs.aws.amazon.com/AmazonECR/latest/userguide/registry_auth.html)

4. Review & Provision the resources using Terraform

```sh
cd terraform
# Review the 'tfvars' file for any changes ('image_tag', 'tags_common', etc.).
terraform init
terraform plan
# review
terraform apply
```

5. Push the local container image to ECR.

The service will be wired up but the ECR is empty. So, the service will cycle a few times (and eventually give up) while looking for the container. So, this is time sensitive the first time.

There are likely consolidated workflows to cut this manual intervention out. But this works around the chicken/egg of the AWS ECR and is relatively simple.

Ensure that `echo $ID` returns the hash you want to upload (see Step 1).

```sh
# tag the hash with the repository url
eval $(terraform output docker_tag)
# push to ECR
eval $(terraform output docker_push)
# wait for a little bit (mileage may vary) and hit the root endpoint
eval $(terraform output hello)
```
