#!/bin/bash
set -e

function deploy_tekton () {
  echo "$(tput setaf 2)===============================================================$(tput setaf 9)"
  echo "$(tput setaf 2)====================== Deploying Tekton =======================$(tput setaf 9)"
  echo "$(tput setaf 2)===============================================================$(tput setaf 9)"
  # Install Tekton
  kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/previous/v0.7.0/release.yaml
  # NOTE: Wait for deploy
  ./utils/wait-for-pods.sh tekton
}

function  docker_registry () {
  echo "$(tput setaf 2)===============================================================$(tput setaf 9)"
  echo "$(tput setaf 2)======= Create Secret For DockerHub and Service Account =======$(tput setaf 9)"
  echo "$(tput setaf 2)===============================================================$(tput setaf 9)"
  # Note: This yaml file creates Secret, which is used to store your DockerHub credentials
  kubectl apply --filename secret.yaml
  # Note: Thic yaml files creates Service Account, which is used to link the build process to the secret
  kubectl apply --filename serviceaacount.yaml

}

function create_PipelineResource () {
  echo "$(tput setaf 2)===============================================================$(tput setaf 9)"
  echo "$(tput setaf 2)======= Create Pipeline Resource For Git and DockerHub ========$(tput setaf 9)"
  echo "$(tput setaf 2)===============================================================$(tput setaf 9)"
  # Note: This file creates Pipeline Resource for Git
  kubectl apply --filename prg.yaml
  # Note: This file creates Pipeline Resource for DockerHub
  kubectl apply --filename prd.yaml
}

function create_Task () {
  echo "$(tput setaf 2)===============================================================$(tput setaf 9)"
  echo "$(tput setaf 2)======= Create Taskm  ========$(tput setaf 9)"
  echo "$(tput setaf 2)===============================================================$(tput setaf 9)"
  # Note: This create Pipeline Resource for Git
  kubectl apply --filename ./task.yaml
}

function create_TaskRun () {
  echo "$(tput setaf 2)===============================================================$(tput setaf 9)"
  echo "$(tput setaf 2)======= Create TaskRun ========$(tput setaf 9)"
  echo "$(tput setaf 2)===============================================================$(tput setaf 9)"
  # Note: This create Pipeline Resource for Git
  kubectl apply --filename ./taskrun.yaml
}

usage() {
  echo "Usage:  ./install.sh deploy_tekton"
  echo "        ./install.sh docker_registry"
  echo "        ./install.sh create_PipelineResource"
  echo "        ./install.sh create_Task"
  echo "        ./install.sh create_TaskRun"
  exit 1
}

if [ $# -eq 0 ]; then
  usage
else
  USERNAME=$1
  PASSWORD=$2
  EMAIL=$3
  case $1 in
    docker_registry) deploy_tekton
    ;;
    deploy_tekton ) deploy_tekton
    ;;
    create_PipelineResource ) create_PipelineResource
    ;;
    create_Task ) create_Task
    ;;
    create_TaskRun ) create_TaskRun
    ;;
    *)
    usage
    exit 1
    ;;
    esac
fi

