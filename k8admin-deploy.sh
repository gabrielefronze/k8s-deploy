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
kubeadm config images pull

echo ""
echo "###########################################################################"
echo "Initializing k8s single control plane cluster backed by Flannel"
echo "###########################################################################"
echo ""
HOST_IP=`hostname --ip-address`
kubeadm init --control-plane-endpoint=$HOST_IP --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=$HOST_IP

echo ""
echo "###########################################################################"
echo "Setting up home configuration"
echo "###########################################################################"
echo ""
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo ""
echo "###########################################################################"
echo "Deploying Flannel network layer"
echo "###########################################################################"
echo ""
sysctl net.bridge.bridge-nf-call-iptables=1
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/2140ac876ef134e0ed5af15c65e414cf26827915/Documentation/kube-flannel.yml

echo ""
echo "###########################################################################"
echo "Allowing control node scheduling"
echo "###########################################################################"
echo ""
kubectl taint nodes --all node-role.kubernetes.io/master-

echo ""
echo "###########################################################################"
echo "Running k8s Dashboard"
echo "###########################################################################"
echo ""
kubectl apply -f recommended-dashboard.yaml
kubectl apply -f adminuser-dashboard.yaml

echo ""
echo "###########################################################################"
echo "Retrieving remote connection token"
echo ""
yum install -y jq
DASHBOARD_TOKEN = $(kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}') -o json | jq -r '.data["token"]' | base64 -d)
echo "Connection token:"
echo $DASHBOARD_TOKEN
unset DASHBOARD_TOKEN
echo "###########################################################################"
echo ""