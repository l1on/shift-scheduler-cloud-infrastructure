if [ "$TF_AUTH_REVOKE" = true ]; then
    gcloud auth application-default revoke -q
fi