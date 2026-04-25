# Example Voting App Project Setup

This repository already came with working Dockerfiles for `vote`, `result`, and `worker`, so the project submission keeps and reuses them instead of replacing them with simpler versions. The main work added here is the infrastructure and deployment scaffolding around the existing microservices app.

## Services

- `vote`: Python frontend
- `result`: Node.js frontend
- `worker`: .NET background worker
- `redis`: official Redis image
- `db`: official Postgres image

## 1. Validate Locally

Build and run the application locally first:

```bash
docker compose up --build
```

Expected local URLs:

- `http://localhost:8080` for the voting page
- `http://localhost:8081` for the results page

## 2. Build and Push Docker Images

Docker Hub username used in this repo: `22i1179`.

```bash
docker build -t 22i1179/vote:v1 ./vote
docker build -t 22i1179/result:v1 ./result
docker build -t 22i1179/worker:v1 ./worker

docker login
docker push 22i1179/vote:v1
docker push 22i1179/result:v1
docker push 22i1179/worker:v1
```

## 3. Provision AWS EC2 with Terraform

Files are in [terraform](/home/laggylegend/Documents/sem-8/cloud-computing/project3/example-voting-app/terraform).

1. Copy `terraform/terraform.tfvars.example` to `terraform/terraform.tfvars`.
2. Set `key_name` to your existing EC2 key pair name.
3. Apply Terraform:

```bash
cd terraform
terraform init
terraform apply
```

Important output:

- `instance_public_ip`

## 4. Configure the Server with Ansible

Files are in [ansible](/home/laggylegend/Documents/sem-8/cloud-computing/project3/example-voting-app/ansible).

1. Copy `ansible/inventory.ini.example` to `ansible/inventory.ini`.
2. Replace the public IP and PEM key path.
3. Run the playbook:

```bash
cd ansible
ansible-playbook playbook.yml
```

The playbook installs Docker and MicroK8s, starts Docker, and adds `ubuntu` to the required groups.

## 5. Deploy to Kubernetes

Files are in [k8s](/home/laggylegend/Documents/sem-8/cloud-computing/project3/example-voting-app/k8s).

1. `k8s/kustomization.yaml` is already configured for Docker Hub username `22i1179`.
2. SSH to the EC2 instance and clone this repository there, or copy the `k8s/` folder to the server.
3. Apply manifests from the repository root on the server:

```bash
git clone https://github.com/mesametamaarkhan/microservices-repo
cd microservices-repo
microk8s status --wait-ready
microk8s kubectl apply -k k8s
```

Expected URLs:

- `http://YOUR_EC2_IP:31000` for `vote`
- `http://YOUR_EC2_IP:31001` for `result`

## 6. GitHub Actions CI

Workflow file:

- [.github/workflows/ci.yml](/home/laggylegend/Documents/sem-8/cloud-computing/project3/example-voting-app/.github/workflows/ci.yml)

Required GitHub secrets:

- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`

On pushes to `main`, the workflow builds and pushes `vote`, `result`, and `worker` images.

## 7. ArgoCD CD

Application manifest:

- [argocd/app.yaml](/home/laggylegend/Documents/sem-8/cloud-computing/project3/example-voting-app/argocd/app.yaml)

Before applying it:

1. `argocd/app.yaml` already points to `https://github.com/mesametamaarkhan/microservices-repo`.
2. Install ArgoCD in MicroK8s:

```bash
microk8s kubectl create namespace argocd
microk8s kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
microk8s kubectl apply -f argocd/app.yaml
```

## 8. Notes for Submission

- Reused the repo's existing service Dockerfiles instead of rewriting them.
- Created separate `terraform`, `ansible`, `k8s`, and `argocd` folders for the project deliverables.
- Kept the original upstream `k8s-specifications/` folder untouched as a reference baseline.
- The `worker` service is `.NET`, so describe it that way in your report.
