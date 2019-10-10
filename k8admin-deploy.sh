#! /bin/bash

touch k8admin-deploy.log

echo "Pulling config images"
kubeadm config images pull >> k8admin-deploy.log

echo "Initializing k8s single control plane cluster backed by Flannel"
HOST_IP=`hostname --ip-address`
kubeadm init --control-plane-endpoint=$HOST_IP --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=$HOST_IP >> k8admin-deploy.log

echo "Deploying Flannel network layer"
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml >> k8admin-deploy.log