#! /bin/bash

echo ""
echo "###########################################################################"
echo "Resetting kubeadmin"
echo "###########################################################################"
echo ""
kubeadm reset
rm -rf ~/.kube

echo ""
echo "###########################################################################"
echo "Resetting iptables"
echo "###########################################################################"
echo ""
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X