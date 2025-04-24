export PROJECT_ID="cache-assessment"
export PROJECT_NUMBER="1021073811386"


# Enable APIs
gcloud services enable artifactregistry.googleapis.com \
  cloudbuild.googleapis.com \
  sqladmin.googleapis.com \
  container.googleapis.com \
  secretmanager.googleapis.com \
  pubsub.googleapis.com \
  compute.googleapis.com \
  iam.googleapis.com \
  servicenetworking.googleapis.com \
  monitoring.googleapis.com \
  storage.googleapis.com 

# Create state bucket
gcloud storage buckets create gs://cache-assessment-tf-state-bucket \
  --location=us-east1 \
  --uniform-bucket-level-access

# Configure CloudBuild to access GKE and AR
gcloud artifacts repositories create cache-assessment-app \
  --repository-format=docker \
  --location=us-east1

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member=serviceAccount:$PROJECT_NUMBER@cloudbuild.gserviceaccount.com \
  --role=roles/artifactregistry.writer # For Artifact Registry access

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member=serviceAccount:$PROJECT_NUMBER@cloudbuild.gserviceaccount.com \
  --role=roles/container.developer # For GKE access

# Create Triggers
gcloud beta builds triggers create github \
  --name="cache-assessment-staging" \
  --repo-name="cache-assessment" \
  --repo-owner="martinkaburu" \
  --branch-pattern="^dev$" \
  --build-config="cloudbuild.yaml" \
  --substitutions=_CLUSTER_NAME=cache-assessment-cluster,_CLUSTER_REGION=us-east1,_ENV=staging,_IMAGE=us-east1-docker.pkg.dev/cache-assessment/cache-assessment-app:$SHORT_SHA-staging


gcloud beta builds triggers create github \
  --name="cache-assessment-prod" \
  --repo-name="cache-assessment" \
  --repo-owner="martinkaburu" \
  --branch-pattern="^main$" \
  --build-config="cloudbuild.yaml" \
  --substitutions=_CLUSTER_NAME="cache-assessment-cluster",_CLUSTER_REGION="us-east1"_ENV="prod",_IMAGE="gcr.io/$PROJECT_ID/cache-assessment-app:$SHORT_SHA-prod"

