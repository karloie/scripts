#!/bin/bash -ex
OS=$(uname -s)
DIST=$(lsb_release -is)
REL=$(lsb_release -cs)
ARCH=$(dpkg --print-architecture)
MACH=$(uname -m)
INIT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# install kubernetes
KUBE_V="1.21.6"
KUBE_KEY="https://packages.cloud.google.com/apt/doc/apt-key.gpg"
KUBE_RECV="307EA071 836F4BEB"
KUBE_REPO="deb [arch=${ARCH,,}] http://apt.kubernetes.io/ kubernetes-xenial main"
apt-key adv --keyserver ${KUBE_KEY} --recv-keys ${KUBE_RECV}
echo ${KUBE_REPO} >/etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y \
    kubeadm=${KUBE_V}-00 \
    kubelet=${KUBE_V}-00 \
    kubectl=${KUBE_V}-00
apt-mark hold \
    kubeadm \
    kubelet \
    kubectl

echo 'KUBELET_EXTRA_ARGS="--fail-swap-on=false"' >/etc/default/kubelet
systemctl restart kubelet

cat <<EOF >/etc/netplan/60-k8s.yml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      link-local: []
EOF
netplan apply

cat <<EOF >/etc/sysctl.d/20-k8s.conf
net.ipv4.ip_forward=1
net.bridge.bridge-nf-call-iptables = 1
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.docker0.disable_ipv6 = 1
net.ipv6.conf.eth0.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF
sysctl --system

# install helm
HELM_V="3.7.1"
HELM_KEY="https://baltocdn.com/helm/signing.asc"
HELM_RECV="1959294AC4827C1A168A"
HELM_REPO="deb [arch=${ARCH,,}] https://baltocdn.com/helm/stable/debian/ all main"
apt-key adv --keyserver ${HELM_KEY} --recv-keys ${HELM_RECV: -8}
echo ${HELM_REPO} >/etc/apt/sources.list.d/helm.list
apt-get update
apt-get install -y helm=${HELM_V}-1
apt-mark hold helm
