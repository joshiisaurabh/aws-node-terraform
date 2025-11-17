# AWS Node Terraform

This project uses **Terraform** to deploy AWS infrastructure for running a Node.js application on an EC2 instance.  
It also creates an **Application Load Balancer (ALB)** along with the necessary **security groups**.

---

## 🚀 Deployment (GitHub Actions)

### ✔ Deploy Workflow (`deploy.yml`) — Runs on Trigger

This workflow runs whenever you trigger it (for example, on push or manual dispatch).

It performs:

- Terraform Init  
- Terraform Validate  
- Terraform Plan  
- Terraform Apply  

This provisions:

- EC2 instance with Node.js application (via user data)  
- Application Load Balancer (ALB)  
- Target Group + Listener  
- Security Groups  
- VPC, subnets, routes, and other required networking resources

---

## 🗑 Destroy Infrastructure

### ⚠ Destroy Workflow (`destroy.yml`) — Manual Trigger

To safely remove all AWS resources:

1. Open the **Actions** tab  
2. Select **Destroy Terraform Resources**  
3. Click **Run workflow**

Keeping this workflow manual prevents accidental deletion of your AWS environment.

---

## 🔑 Required GitHub Secrets

Before running workflows, configure these secrets:

- `AWS_ACCESS_KEY_ID`  
- `AWS_SECRET_ACCESS_KEY`  
- `AWS_REGION`

---

## ▶️ Manual Terraform Usage (Optional)

If you want to deploy manually instead of GitHub Actions:

```bash
terraform init
terraform apply

To destroy manually:
terraform destroy

📌 Summary

Deployment uses deploy.yml and runs on trigger

Creates EC2 + ALB with required security groups

Node.js app automatically installs and runs on EC2

Destroy workflow is manual for safety and cost control
