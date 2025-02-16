# Terraform Deployment Guide

## Overview
This guide provides instructions on how to deploy an AWS EKS cluster along with the required networking components using Terraform.

## Prerequisites
Ensure you have the following installed and configured before running the Terraform script:

- [Terraform](https://www.terraform.io/downloads.html) (version 1.0 or later recommended)
- [AWS CLI](https://aws.amazon.com/cli/) (configured with the necessary access permissions)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) (for interacting with the Kubernetes cluster)

## Steps to Deploy

### 1. Clone the Repository
```sh
git clone <repository_url>
cd <repository_directory>
```

### 2. Initialize Terraform
Run the following command to initialize the Terraform workspace and download the necessary provider plugins:
```sh
terraform init
```

### 3. Validate the Configuration
To verify the configuration files for syntax errors, run:
```sh
terraform validate
```

### 4. Plan the Deployment
To preview the actions Terraform will perform, run:
```sh
terraform plan
```

### 5. Apply the Configuration
To deploy the infrastructure, run:
```sh
terraform apply -auto-approve
```
This will create the following resources:
- A VPC with public and private subnets
- An EKS cluster
- A managed node group
- IAM roles and policies for the cluster and nodes
- A Kubernetes deployment for `SimpleTimeService`
- A Kubernetes service exposed via LoadBalancer

### 6. Configure kubectl
Once the cluster is deployed, configure `kubectl` to interact with it:
```sh
aws eks update-kubeconfig --name simpletimes-cluster-new --region us-east-2
```

### 7. Verify Deployment
Check if the nodes are running:
```sh
kubectl get nodes
```
Check if the Kubernetes deployment and service are running:
```sh
kubectl get deployments
kubectl get services
```

### 8. Get Load Balancer URL
To get the LoadBalancer external IP, run:
```sh
kubectl get svc simpletime-services-new
```

## Cleaning Up
To destroy the resources created by Terraform, run:
```sh
terraform destroy -auto-approve
```

## Notes
- The deployment includes a NAT Gateway for private subnets.
- The application container image is pulled from Docker Hub (`prassinha13/particle41-webapp:latest`).
- Adjust `replicas` in `kubernetes_deployment` if you need to scale the service.

## Troubleshooting
- If `kubectl` cannot connect to the cluster, ensure the kubeconfig is updated.
- Check Terraform logs for any errors if the deployment fails.
- Ensure your AWS credentials have the necessary permissions to create EKS and networking resources.

![Screenshot 2025-02-15 143747](https://github.com/user-attachments/assets/e760f7ec-9924-4ac1-90ac-f6232ba37656)
