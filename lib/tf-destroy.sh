gcloud auth login
export TF_VAR_project_id="$(gcloud projects list  --format="csv[no-heading](PROJECT_ID)")"
gcloud auth revoke -q

gcloud auth application-default login
terraform init && terraform destroy
gcloud auth application-default revoke -q