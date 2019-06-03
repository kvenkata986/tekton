#!/bin/bash
set -e

function deploy_tekton () {
  echo "$(tput setaf 2)===============================================================$(tput setaf 9)"
  echo "$(tput setaf 2)====================== Deploying Tekton =======================$(tput setaf 9)"
  echo "$(tput setaf 2)===============================================================$(tput setaf 9)"
  # Install Tekton
  kubectl apply --filename https://storage.googleapis.com/tekton-releases/latest/release.yaml
  # NOTE: Wait for deploy
  ./utils/wait-for-pods.sh tekton
}

function  docker_registry () {
  USERNAME=$1
  PASSWORD=$2
  EMAIL=$3
  # Create Docker-registry
  kubectl create secret docker-registry registry-secret \
    --docker-server https://index.docker.io/v1/ \
    --docker-username $username \
    --docker-password $password \
    --docker-email $email \
    --namespace default

  kubectl patch secret registry-secret -p='{"metadata":{"annotations": {"tekton.dev/docker-0": "https://index.docker.io/v1/"}}}' \
    --namespace default

  kubectl patch sa default -n default \
    --type=json \
    -p="[{\"op\":\"add\",\"path\":\"/secrets/0\",\"value\":{\"name\": \"registry-secret\"}}]"
}

function create_PipelineResource () {
  echo "$(tput setaf 2)===============================================================$(tput setaf 9)"
  echo "$(tput setaf 2)======= Create Pipeline Resource For Git and DockerHub ========$(tput setaf 9)"
  echo "$(tput setaf 2)===============================================================$(tput setaf 9)"
  # Note: This create Pipeline Resource for Git
  kubectl apply --filename prg.yaml
  # Note: This Creates Pipeline Resource for DockerHub
  kubectl apply --filename prd.yaml
}

function create_task () {
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
  echo "        ./install.sh docker_registry --UserName <NAME> --Password <Password> --Email <Email>  "
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
    docker_registry)
        shift
        if [[ "$1" == "--UserName" ]] || [[ "$2" == "--Password" ]] || [[ "$3" == "--Email" ]]; then
           shift
           if [ "$1" == "" ]; then
              usage
              exit 1
           fi
           USERNAME=$1
           PASSWORD=$2
           EMAIL=$3
           docker_registry $USERNAME $PASSWORD $EMAIL
        else
           usage
           exit 1
        fi
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

