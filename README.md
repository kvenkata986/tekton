---
layout: post
title: "Tekton  Pipelines"
date: 2019-05-27
categories: [wiki]
description: " "
thumbnail: "img/placeholder.jpg"
disable_comments: false
authorbox: true
toc: true
mathjax: true
tags: [dockerhub, kubernetes, helm, tekton, CI/CD Pipeline]
published: true
---

# Overview

In this post, we will go through the basics of Google Tekton and build Tekton pipeline to build container images using Kaniko and publish them to dockerhub. As of now triggering of the build is manual until auto trigger feature is live.

## Goal

Creating a pipeline for building and publishing Container images.

## Prerequisites

To start using Tekton, you need to have:

1. A GitHub account
2. Owner permissions for a project hosted on GitHub.
3. Account and Docker Repository in [DockerHub](https://id.docker.com/login/?next=%2Fid%2Foauth%2Fauthorize%2F%3Fclient_id%3D43f17c5f-9ba4-4f13-853d-9d0074e349a7%26next%3Dhttps%253A%252F%252Fhub.docker.com%252F%26nonce%3DeyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiI0M2YxN2M1Zi05YmE0LTRmMTMtODUzZC05ZDAwNzRlMzQ5YTciLCJleHAiOjE1MzcxNDQzNjAsImlhdCI6MTUzNzE0NDA2MCwicmZwIjoidFpFbTdQN09jdWNJOHhhd04wQldldz09IiwidGFyZ2V0X2xpbmtfdXJpIjoiaHR0cHM6Ly9odWIuZG9ja2VyLmNvbS8ifQ.R5x-qEZ2ihnxVpWvYxLSbF40deBq7kGjiyU8jnX-0l4%26redirect_uri%3Dhttps%253A%252F%252Fhub.docker.com%252Fsso%252Fcallback%26response_type%3Dcode%26scope%3Dopenid%26state%3DeyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiI0M2YxN2M1Zi05YmE0LTRmMTMtODUzZC05ZDAwNzRlMzQ5YTciLCJleHAiOjE1MzcxNDQzNjAsImlhdCI6MTUzNzE0NDA2MCwicmZwIjoidFpFbTdQN09jdWNJOHhhd04wQldldz09IiwidGFyZ2V0X2xpbmtfdXJpIjoiaHR0cHM6Ly9odWIuZG9ja2VyLmNvbS8ifQ.R5x-qEZ2ihnxVpWvYxLSbF40deBq7kGjiyU8jnX-0l4 "DockerHub").
4. Running Kubernetes Environment

## Overview
Tekton Pipelines is an OpenSource project by Google to Build, Run and Maintain CI/CD pipelines for Kubernetes Apps and provides k8s-style resources declaration for CI/CD-style pipelines. Tekton Pipelines are built using Kubernetes CRD’s, it is based on Operator model.

- Steps are fundamental blocks of Pipelines. A step is actually an instance of an image and it is Kubernetes container spec. step contains the actual work to be done.

- Tasks contain a series of steps to be executed in sequential order on the same node, so they can share resources i.e. output/artifacts/parameters of one step to another. Tasks can exist and be invoked completely independently of Pipelines; they are highly cohesive and loosely coupled. Tasks can be invoked via TaskRuns

- Pipelines lets you put together the tasks, so they can run concurrently/Sequentially. They are not guaranteed to execute on the same node, it depends on K8S’s scheduling of pods. But you can have inputs for one task that come from the output of another task, which is specified in the pipeline. They can be triggered by events or by manually creating PipelineRuns

- Pipelines and tasks are declared once and they are used again and again. We create TaskRuns and PipelineRuns to invoke Tasks and PipelineRuns.

- PipelineResources are the artifacts used as inputs and outputs of Tasks.


## Getting Started

1. clone `git clone https://github.com/kvenkata986/tekton.git` and `cd tekton`

2. Install Tekton. This command downloads latest release of tekton and does a `kubectl apply -f  https://storage.googleapis.com/tekton-releases/pipeline/previous/v0.7.0/release.yaml`

		./install.sh deploy_tekton

3. Create Docker Registry Secret and Service Account

        ./install.sh docker_registry

4. Now create `PipelineResource` for Github and DockerHub. Here we specify our git repository and Project in DockerHub were images are pushed

		./install.sh create_PipelineResource

5. Now Create a `Task` which downloads our repo specified in above step from github and using the `Dockerfile` from the downloaded repo, it builds Image using kaniko.

		./install.sh create_task

6. Now Create `TaskRun` to run above pipeline

		./install.sh create_TaskRun

