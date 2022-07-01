#!/usr/bin/env bash

# change mirror then update and upgrade
sed -i.bak -re "s/([a-z]{2}.)?archive.ubuntu.com|security.ubuntu.com/mirror.kakao.com/g" /etc/apt/sources.list
apt-get update && apt-get upgrade -y

# Allow PasswordAuthentication and Permit root login
echo -e 'root\nroot\n' | sudo passwd root
sed -i.bak -r 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i.bak -r 's/PermitRootLogin prohibit-password/PermitRootLogin prohibit-password\nPermitRootLogin yes/' /etc/ssh/sshd_config
service ssh restart
service sshd restart

# Swap disabled. You MUST disable swap in order for the kubelet to work properly
# swapoff -a to disable swapping and
swapoff -a
# sed to comment the swap partition in /etc/fstab
sed -i.bak -r 's/(.+ swap .+)/#\1/' /etc/fstab

# Forwarding IPv4 and letting iptables see bridged traffic
# Verify that the br_netfilter module is loaded by running lsmod | grep br_netfilter.
cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
# To load it explicitly, run sudo modprobe br_netfilter.
modprobe overlay
modprobe br_netfilter
# In order for a Linux node's iptables to correctly view bridged traffic,
# verify that net.bridge.bridge-nf-call-iptables is set to 1 in your sysctl config
# sysctl params required by setup, params persist across reboots
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

# local small dns & vagrant cannot parse and delivery shell code.
echo "192.168.56.100 kubernetes-master-node" >> /etc/hosts
for (( i=1; i<=$1; i++  )); do echo "192.168.56.10$i kubernetes-worker-node-$i" >> /etc/hosts; done

# config DNS  
cat <<EOF > /etc/resolv.conf
nameserver 1.1.1.1 #cloudflare DNS
nameserver 8.8.8.8 #Google DNS
EOF

