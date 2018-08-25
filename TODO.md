In project_and_srv_accounts/create_project_and_service_account
3. create a service account named "admin-automation" instead of “terraform"
4. use "gcloud auth application-default login" instead of gcloud auth login 
5. replace "../auth/remove_service_account_cred" with "gcloud auth application-default revoke"
6. create a gcp bucket

Remove auth/

In kubernetes-cluster/create, use "gcloud auth application-default login"
Change kubernetes-cluster/remove accordingly

In install_tiller, use # Get kube cluster access credentials from create_service_account_cred

change setup and teardown accordingly

create a another folder called "create-automation-service-account" and write a script to automate the creation of service account, creation of service account key file and moving the file to shift-sheduler-deployment repo and then encryp it and possiably git commit and git push
