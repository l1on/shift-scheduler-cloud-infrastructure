GOOGLE_APPLICATION_CREDENTIALS=~/.config/gcloud/terraform-admin.json

gcloud auth revoke

rm "${GOOGLE_APPLICATION_CREDENTIALS}"