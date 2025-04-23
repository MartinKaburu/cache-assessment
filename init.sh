export PROJECT_ID="martin-sandbox-272210"
export PROJECT_NUMBER="822635471166"


# Configure CloudBuild to access GKE and AR
gcloud services enable cloudbuild.googleapis.com
gcloud services enable artifactregistry.googleapis.com

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
  --substitutions=_CLUSTER_NAME="cache-assessment-cluster",_CLUSTER_REGION="us-east1"_ENV="staging",_IMAGE="gcr.io/$PROJECT_ID/cache-assessment-app:staging-$SHORT_SHA-staging"

gcloud beta builds triggers create github \
  --name="cache-assessment-prod" \
  --repo-name="cache-assessment" \
  --repo-owner="martinkaburu" \
  --branch-pattern="^main$" \
  --build-config="cloudbuild.yaml" \
  --substitutions=_CLUSTER_NAME="cache-assessment-cluster",_CLUSTER_REGION="us-east1"_ENV="prod",_IMAGE="gcr.io/$PROJECT_ID/cache-assessment-app:prod-$SHORT_SHA-prod"

