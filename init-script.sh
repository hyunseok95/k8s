#!/usr/bin/env bash

# install docker-registry
$HOME/workspace/k8s/docker-registry/install.sh 1

# install metallb
$HOME/workspace/k8s/metallb-bitnami/install.sh

# install jenkins
$HOME/workspace/k8s/jenkins/install.sh


