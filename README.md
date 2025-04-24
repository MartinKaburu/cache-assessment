## Cache Assessment: Infrastructure and Application Deployment Documentation

### Overview
This document outlines the infrastructure setup and application deployment process for the Cache assessment. The infrastructure is provisioned using **Terraform** and deployed on **Google Cloud Platform (GCP)**. The stack includes **GKE**, **Cloud SQL**, **Pub/Sub**, **ELK Stack (Elasticsearch, Logstash, Kibana)**, and **Fluent Bit** for observability. CI/CD is implemented via **Cloud Build**.

---

## Terraform Configuration

### Modules Used:

#### 1. **VPC Module**
- **Purpose**: Create a production-grade Virtual Private Cloud (VPC) with public and private subnets.
- **Configuration**:
  - **Public Subnet**: Hosts the bastion instance.
  - **Private Subnet**: Hosts GKE and Cloud SQL.
  - **NAT Gateway**: Allows private subnet egress.
  - **Bastion Instance**: Deployed in the public subnet. Accessed with `gcloud compute ssh debian@cache-net-bastion --zone=us-east1-b`
- **Outputs**:
  - `network` (VPC self-link)
  - `public_subnet` (self-link)
  - `private_subnet` (self-link)

#### 2. **GKE Module**
- **Purpose**: Deploy a **private GKE cluster** in the private subnet.
- **Configuration**:
  - **Cluster Name**: Defined via variable.
  - **Subnetwork**: Uses the `private_subnet` from the VPC module.
  - **Node Count**: Set to **6 nodes**. 2 Nodes per Zone.
- **IAM**: Configured to use **Workload Identity** for secure pod-to-GCP interactions.

#### 3. **Cloud SQL Module**
- **Purpose**: Provision a **PostgreSQL instance** in the private network.
- **Configuration**:
  - **Private IP only** (no public IP).
  - **Private Service Access** enabled.
  - **Secrets**: Auto-generates DB password and stores it in **Secret Manager**.
- **Outputs**:
  - **DB connection string**.
  - **Secret Manager references**.

**NOTE: I would not share the same VPC, GKE or SQL Instance for prod and staging this is just for demonstration purposes.**

#### 4. **Pub/Sub Module**
- **Purpose**: Create a **Pub/Sub topic and subscription**.
- **Configuration**:
  - **Topic Name** and **Subscription Name** defined via variables.

#### 5. **ELK Stack (Helm)**
- **Purpose**: Deploy **Elasticsearch** and **Kibana** via Helm.
- **Configuration**:
  - **Namespace**: `elastic-system`.
  - **Elasticsearch Replicas**: 1 (for development).
  - **Kibana**: Exposed via LoadBalancer for external access.

#### 6. **Fluent Bit (Helm)**
- **Purpose**: Forward **GKE logs** to **Elasticsearch**.
- **Configuration**:
  - **Elasticsearch Output Plugin** configured with **internal cluster service**.

#### 7. **Service Accounts and IAM**
- **GKE App Service Account**: Grants **Pub/Sub publisher** role.
- **External Secrets Operator (ESO) Service Account**:
  - Grants **Secret Manager accessor**.
  - Binds Kubernetes Service Account (**eso-ksa**) to GCP Service Account (**eso-gsa**) via **Workload Identity**.

---

## Application Deployment

### Flask App
- **Purpose**: Demonstrates integration with **Pub/Sub**, **PostgreSQL**, and **ELK**.
- **Key Features**:
  - Publishes messages to **Pub/Sub** every **5 minutes**.
  - Inserts messages into **PostgreSQL**.
  - Emits **structured JSON logs** (ELK ingestible).
  - Exposes a `/health` endpoint.
- **DB Table Management**:
  - On startup, checks if the **`messages` table** exists.
  - Creates the table if missing.

---

## CI/CD Pipeline (Cloud Build)

### Build & Deploy Steps:
1. **Build Docker Image**:
   - Tag: `us-east1-docker.pkg.dev/$PROJECT_ID/cache-assessment-app:$SHORT_SHA-{env}`
2. **Push Docker Image**:
   - Pushes to **Artifact Registry**.
3. **Deploy to GKE**:
   - Uses **kubectl kustomize** to generate manifests.
   - **Injects the image tag** dynamically.
   - Applies manifests to the **GKE cluster**.

### Substitutions:
- `_IMAGE`: Fully qualified image tag.
- `_CLUSTER_NAME`: GKE cluster name.
- `_CLUSTER_REGION`: GKE region.
- `_ENV`: `staging` or `prod`.

---

## Security Considerations
- **Workload Identity** ensures **secure pod-GCP interactions** without long-lived keys.
- **Private networking** for **GKE** and **Cloud SQL**.
- **Bastion host** in public subnet for secure SSH access.
- **Secret Manager** used for storing sensitive DB credentials.
- **ESO (External Secrets Operator)** automatically syncs secrets into Kubernetes.

---

## Observability
- **Fluent Bit** forwards logs to **Elasticsearch**.
- **Kibana** provides log visualization.
- **Index pattern**: `cache-logs-*`.

---

## Future Improvements
- Add **TLS encryption** for **ELK Stack**.
- Implement **RBAC** for **Kibana** access.
- Scale **Elasticsearch** to multiple nodes for production.
- Refactor the codebase to have an `infra/environments/shared` module that houses all the shared resources like SQL and GKE
