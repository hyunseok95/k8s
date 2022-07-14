#!/usr/bin/env bash

# Update the apt package index and install util
apt-get update
apt-get install -y \
vim \
git-all \
sshpass \
nfs-kernel-server \
nfs-common

# Update the apt package index and install packages to allow apt to use a repository over HTTPS
apt-get update
apt-get install -y ca-certificates curl gnupg lsb-release apt-transport-https


#===============================#
# Install Docker and Containerd #
#===============================#

# Uninstall old versions of Docker
apt-get remove -y docker docker-engine docker.io containerd runc

# Add Docker’s official GPG key
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Use the following command to set up the repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
apt-mark hold docker-ce docker-ce-cli containerd.io docker-compose-plugin
systemctl enable --now docker
systemctl enable --now containerd

# Changing the settings such that docker use systemd as the cgroup driver
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
mkdir -p /etc/systemd/system/docker.service.d

# Changing the settings such that containerd use systemd as the cgroup driver
containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

systemctl daemon-reload
systemctl restart docker
systemctl restart containerd

#====================#
# Install Kubernetes #
#====================#

# Download the Google Cloud public signing key
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

# Add the Kubernetes apt repository
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list

# Update apt package index, install kubelet, kubeadm and kubectl, and pin their version
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
systemctl enable --now kubelet

# Update and upgrade
apt-get update && apt-get upgrade -y