#! /bin/bash

echo "Disable SELinux"
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

echo "Disable SWAP"
swapoff -a
sed -e '/swap/ s/^#*/#/' -i /etc/fstab

echo "Enable br-netfilter"
modprobe br_netfilter
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables

echo "Install/upgrade Docker-ce"
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce

echo "Install k8s"
cp -f kubernetes.repo /etc/yum.repos.d/kubernetes.repo
yum install -y kubelet kubeadm kubectl

echo "Reboot machine!"