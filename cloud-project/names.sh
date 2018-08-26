#!/bin/bash

export PROJECT_ROOT=shift-scheduler
export SERVICE_ACCOUNT=ci-deploy

export TF_VAR_bucket_name=${PROJECT_ROOT}-terraform-state
export TF_VAR_cluster_name=${PROJECT_ROOT}
export TF_VAR_cluster_zone=us-central1-a