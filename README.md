⚠️ Important – Terraform Backend
Before running Terraform, you must update the backend configuration to your own.
Edit:
infra/terraform/backend.tf
Replace:
S3 bucket name
DynamoDB table name
Use your own S3 bucket and DynamoDB table.

Please have a look on the attached .png that explain the cloud architecture of this assignment :)

Deploy Infrastructure instructions:

First, please make sure you have the docker images in your ECR.
example of how to build the producer image run the below commands (same for producer, just change path and names):
cd infra/terraform
terraform init
export PRODUCER_REPO=$(terraform output -raw producer_ecr_repo_url)
cd app/producer-service
docker login # please login to your ecr
docker build . -t $PRODUCER_REPO:latest
docker push $PRODUCER_REPO:latest
# please do the same for consumer, please note that ecr repo is not the same for both images. 

terraform apply -auto-approve \
  -var="token_value=CHANGE_ME" \
  -var="allowed_ingress_cidr=<YOUR_PUBLIC_IP>/32"

Test the application:
1. terraform output alb_dns_name → Get load balancer address
2. curl http://<ALB_DNS_NAME>/health → Test producer health expected output: {"status":"ok"}
3. use request_example.json from repository or create your own in the next command
4. curl -X POST http://<ALB_DNS_NAME>/produce -H "Content-Type: application/json" -H "X-API-Token: CHANGE_ME" --data-binary "@request.json"
5. Check S3 bucket, it should contain: events/YYYY-MM-DD/<SOME_FILE_WITH_RESPOSE>


Cleanup:
cd infra/terraform
terraform destroy -auto-approve