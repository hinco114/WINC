# WINC

Whitenose Integrates Nomadic Circuit

## What is WINC?

The first purpose of WINC is to provide my personal devops environment for my test and study.
But If you want to use this WINC, you can use it.
I'll do my best to make it easy to use using Terraform, GitOps, Environment Variables, and so on.

## What is included?

-   Terraform codes (for AWS)
-   GitOps codes (for Kubernetes)
    -   Support EKS, NAS.
-   DevOps tools
    -   ArgoCD
    -   Rancher
    -   Telepresence

## Requirements

1. terraform - 1.9.8
2. eksctl - 0.194.0
3. kubectl 1.30.2

## How to use?

1. Set `.env` file using `.env.example` file. Recommanded to use `direnv`.

## Environment Variables

Table of Environment Variables

| Name                  | Description           | Default | Required                  | Allowed Values        |
| --------------------- | --------------------- | ------- | ------------------------- | --------------------- |
| AWS_ACCESS_KEY_ID     | AWS Access Key ID     |         | Yes                       | AWS provided value    |
| AWS_SECRET_ACCESS_KEY | AWS Secret Access Key |         | Yes                       | AWS provided value    |
| GITHUB_ID             | Github ID             |         | If use private repository | Github provided value |
| GITHUB_SECRET         | Github Secret         |         | If use private repository | Github provided value |
