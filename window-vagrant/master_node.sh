#!/usr/bin/env bash

#========================================#
# make work directory and clone git repo #
#========================================#

# Make work directory
mkdir $HOME/workspace

# git clone k8s.git
git clone https://github.com/hyunseok95/k8s.git
mv /home/vagrant/k8s $HOME/workspace
find $HOME/workspace/k8s/ -regex ".*\.\(sh\)" -exec chmod 700 {} \;

#======================================#
# Initializing your control-plane node #
#======================================#

# The control-plane node is the machine where the control plane components run, including etcd (the cluster database)
# and the API Server (which the kubectl command line tool communicates with).
sudo kubeadm init \
--control-plane-endpoint 192.168.56.1 \
--apiserver-advertise-address 192.168.56.1 \
--pod-network-cidr 172.16.0.0/16 \
--token 123456.1234567890123456 \
--token-ttl 0

# config for master node only
# To make kubectl work for your non-root user, run these commands
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# You should now deploy a Pod network to the cluster
# with one of the options listed  at: /docs/concepts/cluster-administration/addons/
kubectl create -f https://projectcalico.docs.tigera.io/manifests/tigera-operator.yaml
kubectl create -f $HOME/hyunseok/workspace/kubernetes/k8s/window-vagrant/calico-config.yaml

#==============#
# Install Helm #
#==============#

mkdir $HOME/workspace/helm
curl -fsSL -o $HOME/workspace/helm/get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 $HOME/workspace/helm/get_helm.sh
$HOME/workspace/helm/get_helm.sh



