# Microservices Deployment Guide

This repository contains a simple microservices voting application and the deployment assets used to run it with Docker, Terraform, Ansible, Kubernetes, GitHub Actions, and ArgoCD.

## Application Overview

Services in this project:

- `vote`: Python frontend where users cast votes
- `result`: Node.js frontend that displays live results
- `worker`: .NET backend worker that moves votes from Redis to Postgres
- `redis`: message queue
- `db`: PostgreSQL database

Architecture:

![Architecture diagram](architecture.excalidraw.png)

## Repository Structure

- `vote/`
- `result/`
- `worker/`
- `terraform/`
- `ansible/`
- `k8s/`
- `argocd/`
- `.github/workflows/`

## 1. Run Locally with Docker Compose

Use Docker Compose to confirm the application works before deploying it.

```bash
docker compose up --build
```

Local URLs:

- `http://localhost:8080` for the voting app
- `http://localhost:8081` for the result app

## 2. Build and Push Docker Images

This project uses Docker Hub username `22i1179`.

Build the service images:

```bash
docker build -t 22i1179/vote:v1 ./vote
docker build -t 22i1179/result:v1 ./result
docker build -t 22i1179/worker:v1 ./worker
```

Push them to Docker Hub:

```bash
docker login
docker push 22i1179/vote:v1
docker push 22i1179/result:v1
docker push 22i1179/worker:v1
```

## 3. Provision AWS Infrastructure with Terraform

Terraform files are in `terraform/`.

The Terraform configuration:

- creates an Ubuntu EC2 instance
- creates a security group
- opens ports for SSH and Kubernetes NodePort access
- outputs the public IP and SSH command

Run:

```bash
cd terraform
terraform init
terraform apply
```

Important values:

- `key_name` in `terraform/terraform.tfvars` must match the EC2 key pair name in AWS
- save the `instance_public_ip` output

## 4. Configure the EC2 Instance with Ansible

Ansible files are in `ansible/`.

Update `ansible/inventory.ini` with the EC2 public IP, then run:

```bash
cd ansible
ansible-playbook playbook.yml
```

The playbook:

- updates apt packages
- installs Docker
- installs MicroK8s
- adds the `ubuntu` user to `docker` and `microk8s` groups
- enables MicroK8s DNS

## 5. Deploy the Application to Kubernetes

Kubernetes manifests are in `k8s/`.

The file `k8s/kustomization.yaml` is already configured to use:

- `22i1179/vote:v1`
- `22i1179/result:v1`
- `22i1179/worker:v1`

SSH into the EC2 instance:

```bash
ssh -i /path/to/your-key.pem ubuntu@YOUR_EC2_IP
```

On the server:

```bash
git clone https://github.com/mesametamaarkhan/microservices-repo
cd microservices-repo
microk8s status --wait-ready
microk8s kubectl apply -k k8s
microk8s kubectl get pods
microk8s kubectl get svc
```

Application URLs:

- `http://YOUR_EC2_IP:31000` for `vote`
- `http://YOUR_EC2_IP:31001` for `result`

## 6. Verify Kubernetes and MicroK8s

Useful commands on the EC2 server:

```bash
microk8s status --wait-ready
microk8s kubectl get nodes
microk8s kubectl get pods
microk8s kubectl get svc
microk8s kubectl get deployments
microk8s kubectl get all
```

For ArgoCD namespace:

```bash
microk8s kubectl get pods -n argocd
microk8s kubectl get svc -n argocd
microk8s kubectl get applications -n argocd
```

For debugging:

```bash
microk8s kubectl describe pod <pod-name>
microk8s kubectl logs <pod-name>
```

## 7. Set Up GitHub Actions CI

CI workflow file:

- `.github/workflows/ci.yml`

Required GitHub repository secrets:

- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`

The workflow runs on pushes to `main` and:

- builds `vote`, `result`, and `worker`
- logs in to Docker Hub
- pushes images to Docker Hub

To trigger CI manually:

```bash
git commit --allow-empty -m "Trigger CI"
git push origin main
```

## 8. Set Up ArgoCD

ArgoCD application manifest:

- `argocd/app.yaml`

On the EC2 server:

```bash
cd ~/microservices-repo
microk8s kubectl create namespace argocd
microk8s kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
microk8s kubectl apply -f argocd/app.yaml
microk8s kubectl get applications -n argocd
microk8s kubectl get pods -n argocd
```

To access the ArgoCD UI:

```bash
microk8s kubectl port-forward svc/argocd-server -n argocd 8080:443 --address 0.0.0.0
```

Open:

- `https://YOUR_EC2_IP:8080`

Get the initial password:

```bash
microk8s kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

Login:

- username: `admin`
- password: output of the command above

## 9. Submission Checklist

Include screenshots or proof of:

- successful `terraform apply`
- successful `ansible-playbook playbook.yml`
- Docker Hub images pushed successfully
- running Kubernetes pods and services
- working `vote` and `result` application pages
- successful GitHub Actions CI run
- ArgoCD app created and synced

## Notes

- The project reuses the existing Dockerfiles already present in the repo.
- The `worker` service is `.NET`, not Python.
- The original upstream `k8s-specifications/` folder is kept as reference, while `k8s/` contains the submission-focused deployment manifests.
