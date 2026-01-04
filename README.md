## ⚠️ Important – Terraform Backend Configuration
Before running Terraform, you **must** update the backend configuration to use **your own AWS resources**.  
Edit the following file: `infra/terraform/backend.tf`  
Replace the **S3 bucket name** and **DynamoDB table name** with your own.  
These are required for Terraform remote state storage and state locking.

## 📐 Architecture Overview
Please refer to the attached `.png` file in the repository, which illustrates the cloud architecture used in this assignment.

## 🚀 Deploy Infrastructure Instructions
Before applying Terraform, make sure **both Docker images** (producer and consumer) are built and pushed to **their respective ECR repositories**.
Example for the **producer service** (repeat the same steps for the consumer service, changing paths and repository names):

Note: Producer and consumer use different ECR repositories.

Apply Terraform:
```bash
cd infra/terraform
terraform apply -auto-approve \
  -var="token_value=CHANGE_ME" \
  -var="allowed_ingress_cidr=<YOUR_PUBLIC_IP>/32" \
  -var="producer_image_tag=latest" \
  -var="consumer_image_tag=latest"
```

Build and push the docker images: 
```bash
cd infra/terraform
terraform init
export PRODUCER_REPO=$(terraform output -raw producer_ecr_repo_url)
cd ../../app/producer-service
docker login
docker build . -t $PRODUCER_REPO:latest
docker push $PRODUCER_REPO:latest
```

🧪 Test the Application
Get the ALB DNS name:
```bash
terraform output alb_dns_name
```

Test producer health endpoint:
```bash
curl http://<ALB_DNS_NAME>/health → expected: {"status":"ok"}
```

Send a request to the producer (use request_example.json or create your own):
```bash 
curl -X POST http://<ALB_DNS_NAME>/produce -H "Content-Type: application/json" -H "X-API-Token: CHANGE_ME" --data-binary "@request.json"
```

Verify the output in the S3 bucket.
Expected object path format:
events/YYYY-MM-DD/<GENERATED_RESPONSE_FILE>

🧹 Cleanup
```bash
cd infra/terraform
terraform destroy -auto-approve
```