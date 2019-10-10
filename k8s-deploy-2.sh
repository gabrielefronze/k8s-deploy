echo "Adding k8s to Docker-ce Cgroup"
sed -i 's/cgroup-driver=systemd/cgroup-driver=cgroupfs/g' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
systemctl daemon-reload
systemctl restart kubelet

echo "Initializing k8s cluster"
HOST_IP=`hostname --ip-address`
HOST_SNM=$(ip -o -f inet addr show | awk '/scope global/ {print $4}' | grep $HOST_IP)
kubeadm init --apiserver-advertise-address=$HOST_IP --pod-network-cidr=$HOST_SNM 2>&1 | tee ~/kubeadm-init.log

echo "Enable br-netfilter"
modprobe br_netfilter
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables

echo "Configuring k8s"
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "Deploying flannel network"
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

echo "Deploying dashboard"
curl https://raw.githubusercontent.com/kubernetes/dashboard/latest/aio/deploy/recommended.yaml > recommended.yaml
kubectl apply -f recommended.yaml
kubectl apply -f dashboard-adminuser.yaml
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')

