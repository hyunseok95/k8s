#!/usr/bin/env bash

#==========================#
# Joining your worker node #
#==========================#

# You can now join any number of machines by running the following on each node
kubeadm join 10.253.26.1:6443 \
--token 123456.1234567890123456 \
--discovery-token-unsafe-skip-ca-verification \
--v 5
