#!/bin/bash
set -e

echo "================ Installing Dependencies ================"

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get upgrade -y
apt-get install -y \
    curl \
    wget \
    vim \
    jq \
    git \
    unzip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    build-essential \
    python3-pip

pip3 install jc

###########################################################
# Install Containerd
###########################################################

echo "================ Installing Containerd ================"

apt-get install -y containerd

mkdir -p /etc/containerd
containerd config default >/etc/containerd/config.toml

sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' \
/etc/containerd/config.toml

systemctl restart containerd
systemctl enable containerd

###########################################################
# Disable Swap
###########################################################

swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

###########################################################
# Kernel Modules
###########################################################

cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.ip_forward=1
EOF

sysctl --system

###########################################################
# Kubernetes Repository
###########################################################

mkdir -p /etc/apt/keyrings

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key \
| gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo \
'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' \
| tee /etc/apt/sources.list.d/kubernetes.list

apt-get update

###########################################################
# Install Kubernetes
###########################################################

apt-get install -y \
kubelet \
kubeadm \
kubectl

apt-mark hold kubelet kubeadm kubectl

systemctl enable kubelet

###########################################################
# Kubernetes Cluster Initialization
###########################################################

echo "================ Initializing Cluster ================"

kubeadm reset -f || true

kubeadm init \
--pod-network-cidr=192.168.0.0/16

mkdir -p $HOME/.kube
cp /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

###########################################################
# Install Calico CNI
###########################################################

kubectl apply -f \
https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/calico.yaml

###########################################################
# Allow Pods on Control Plane
###########################################################

kubectl taint nodes --all \
node-role.kubernetes.io/control-plane:NoSchedule- || true

###########################################################
# Install Java
###########################################################

echo "================ Installing Java ================"

apt-get install -y openjdk-17-jdk

java -version

###########################################################
# Install Maven
###########################################################

apt-get install -y maven

mvn -version

###########################################################
# Install Jenkins
###########################################################

echo "================ Installing Jenkins ================"

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key \
| tee /usr/share/keyrings/jenkins-keyring.asc >/dev/null

echo deb \
[signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/ \
| tee /etc/apt/sources.list.d/jenkins.list >/dev/null

apt-get update

apt-get install -y jenkins

systemctl daemon-reload
systemctl enable jenkins
systemctl start jenkins

###########################################################
# Jenkins Permissions
###########################################################

usermod -aG docker jenkins || true

echo "jenkins ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

###########################################################
# Display Versions
###########################################################

echo
echo "========== Installed Versions =========="

kubectl version --client
kubeadm version
kubelet --version
java -version
mvn -version
systemctl status jenkins --no-pager
