# FastAPI on AWS: Terraform + CI/CD

Slide deck content for the project. Each section is one slide, followed by its speaker notes.

---

## 1. FastAPI on AWS

**Terraform, GitHub OIDC and App Runner**

An Azure CI/CD project rebuilt for AWS.

> Notes: This deck summarises the repo: infrastructure as code, a containerised API, and a pipeline with no stored credentials.

---

## 2. Azure pieces swapped for AWS equivalents

| Concept | Azure | AWS |
|---|---|---|
| Registry | ACR | ECR |
| Runtime | App Service | App Runner |
| Pull identity | Managed Identity | IAM roles |
| Secrets | Key Vault | Secrets Manager |
| Monitoring | Application Insights | CloudWatch |
| CI auth | GitHub OIDC to Azure | GitHub OIDC to AWS IAM |

> Notes: App Runner was chosen over ECS Fargate because it is the closest match to App Service and gives public HTTPS without a domain or certificate.

---

## 3. Every push to main ships itself

1. **Test**: pytest and Terraform validate
2. **Build**: Docker image with commit SHA
3. **Push**: tags `:sha` and `:latest` to ECR
4. **Deploy**: App Runner rolls out `:latest`
5. **Verify**: `/health` must report the SHA

> Notes: The smoke test polls the health endpoint until the new commit is live, so a failed rollout fails the pipeline.

---

## 4. No long-lived credentials anywhere

- **GitHub OIDC role**: only `main` of one repo can assume it, and it can push to one ECR repository.
- **Access role**: App Runner uses it to pull the image from ECR, nothing more.
- **Instance role**: the running container can read exactly one Secrets Manager secret.

> Notes: Secrets are injected at runtime and never appear in the image, the repo, or the `/config` response.

---

## 5. Two-stage first deploy

1. Apply Terraform with `deploy_service = false`
2. Push to `main` so CI pushes the first image
3. Set `deploy_service = true` and apply again
4. Every later push redeploys automatically

App Runner cannot start until an image exists in ECR.

> Notes: Set `github_repo` in `terraform.tfvars` first, and set `create_github_oidc_provider = false` if the account already has a GitHub OIDC provider.

---

## 6. Monitoring, status and next steps

- **Monitoring**: CloudWatch logs and metrics, plus a 5xx alarm that emails through SNS.
- **Status**: five unit tests pass. Terraform is not yet applied to a live account, so expect small fixes.
- **Next**: Terraform plan on pull requests, S3 remote state, or ECS Fargate with an ALB.

Cleanup: run `terraform destroy`, because App Runner bills for idle memory.

> Notes: Close by pointing to the README for setup and cleanup steps.
