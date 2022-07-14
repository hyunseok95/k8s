#!/usr/bin/env bash

#===================#
# Joining your node #
#===================#

# You can now join any number of machines by running the following on each node
sudo kubeadm join 192.168.1.1:6443 \
--token 123456.1234567890123456 \
--discovery-token-unsafe-skip-ca-verification \
--v 5
