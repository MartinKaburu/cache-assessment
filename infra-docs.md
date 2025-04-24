## IAM Audit and SOC 2 Alignment

### Current IAM Configuration:

- **Workload Identity (GKE Pods → GCP Services)**:
  - GKE app pods use **Kubernetes Service Account (KSA)** bound to **GCP Service Account (GSA)**.
  - **IAM Role**: `roles/pubsub.publisher` assigned to GSA for Pub/Sub access.
  - **IAM Role**: `roles/secretmanager.secretAccessor` assigned to ESO GSA.
  - **IAM Binding**: Workload Identity (`roles/iam.workloadIdentityUser`) between GSA and KSA.

- **Cloud Build Service Account**:
  - Roles:
    - `roles/container.developer` (GKE deploy)
    - `roles/artifactregistry.writer` (Artifact Registry push)

- **Bastion Host SSH Access**:
  - **SSH keys** per user (individual key pairs).
  - **SSH audit logs** tracked via `/var/log/auth.log`.
  - Logs can be forwarded via **Fluent Bit** (Future improvement).

---

### SOC 2 Alignment Considerations:

- **Current Alignments**:
  - **Principle of Least Privilege**:
    - IAM roles are scoped tightly per service (e.g., Pub/Sub, Secret Manager).
  - **Secrets Management**:
    - **GCP Secret Manager** used for sensitive data.
    - **External Secrets Operator (ESO)** syncs secrets securely into Kubernetes.
  - **Audit Logging**:
    - SSH access logs captured on the bastion.
    - **Kubernetes audit logs** (available via GKE API).

---

### Future Improvements:

- **Centralize Logs**:
  - Forward **bastion SSH logs** and **GKE audit logs** to **ELK Stack** or **Cloud Logging**.

- **Enhance Bastion Auditing**:
  - Implement **`auditd`** to capture **command execution**.
  - Forward logs to **SIEM** (Security Information and Event Management).

- **RBAC Enhancements**:
  - Apply **fine-grained Kubernetes RBAC policies** for pod-level access.
  - Integrate **Kibana RBAC** for log access control.

- **OS Login (GCP)**:
  - Replace SSH key management with **IAM-based OS Login** for the bastion.
  - Enables **centralized user tracking**.

- **TLS for ELK Stack**:
  - Secure Elasticsearch and Kibana traffic with **TLS encryption**.

- **Regular IAM Reviews**:
  - Schedule **quarterly IAM audits** to ensure compliance.

---

This setup aligns with **SOC 2** principles for **security, availability, and confidentiality**, with room for continuous improvement.

