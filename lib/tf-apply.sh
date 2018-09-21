script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

source ${script_dir}/bash-login.sh
export TF_VAR_project_id="$(gcloud projects list --format="csv[no-heading](PROJECT_ID)")"
source ${script_dir}/bash-logout.sh

source ${script_dir}/tf-login.sh
terraform init && terraform apply -auto-approve
source ${script_dir}/tf-logout.sh
