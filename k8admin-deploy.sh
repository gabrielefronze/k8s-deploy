#! /bin/bash

echo ""
echo "###########################################################################"
echo "Setting up Docker to use systemd groups"
echo "###########################################################################"
echo ""
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF

mkdir -p /etc/systemd/system/docker.service.d

systemctl daemon-reload
systemctl restart docker

echo ""
echo "###########################################################################"
echo "Pulling config images"
echo "###########################################################################"
echo ""
kubeadm config images pull >> k8admin-deploy.log

echo ""
echo "###########################################################################"
echo "Initializing k8s single control plane cluster backed by Flannel"
echo "###########################################################################"
echo ""
HOST_IP=`hostname --ip-address`
kubeadm init --control-plane-endpoint=$HOST_IP --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=$HOST_IP >> k8admin-deploy.log

echo ""
echo "###########################################################################"
echo "Deploying Flannel network layer"
echo "###########################################################################"
echo ""
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml >> k8admin-deploy.log