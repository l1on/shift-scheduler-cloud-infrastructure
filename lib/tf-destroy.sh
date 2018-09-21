source bash-login.sh
export TF_VAR_project_id="$(gcloud projects list --format="csv[no-heading](PROJECT_ID)")"
source bash-logout.sh

source tf-login.sh
terraform init && terraform destroy
source tf-logout.sh