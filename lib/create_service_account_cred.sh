export GOOGLE_APPLICATION_CREDENTIALS=~/.config/gcloud/terraform-admin.json

gcloud auth login

export TF_VAR_project_id="$(gcloud projects list  --format="csv[no-heading](PROJECT_ID)")"

gcloud iam service-accounts keys create "${GOOGLE_APPLICATION_CREDENTIALS}" --iam-account terraform@"${TF_VAR_project_id}".iam.gserviceaccount.com