#!/usr/bin/bash
#sudo yum -y update

#Don't forget to add ips for your servers in /etc/hosts

sudo setenforce 0
sudo sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config

sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a

#install Docker
sudo yum install -y http://mirror.centos.org/centos/7/extras/x86_64/Packages/container-selinux-2.119.2-1.911c772.el7_8.noarch.rpm
sudo yum install -y https://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/f/fuse3-libs-3.6.1-2.el7.x86_64.rpm
sudo yum install -y http://mirror.centos.org/centos/7/extras/x86_64/Packages/fuse-overlayfs-0.7.2-6.el7_8.x86_64.rpm
sudo yum install -y http://mirror.centos.org/centos/7/extras/x86_64/Packages/slirp4netns-0.4.3-4.el7_8.x86_64.rpm

sudo yum install -y yum-utils

sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

sudo yum -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl enable docker
sudo systemctl start docker

sudo usermod -aG docker $USER
sudo usermod -aG docker $USER

newgrp docker

#Kubernetes Installation

sudo tee /etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

sudo yum clean all && sudo yum -y makecache

sudo yum -y install epel-release vim git curl wget kubelet kubeadm kubectl --disableexcludes=kubernetes

sudo systemctl enable kubelet
sudo systemctl start kubelet

sudo vi /etc/containerd/config.toml

#in this step you have to enter this in file

: '

disabled_plugins = []
enabled_plugins = ["cri"]

[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runsc]
runtime_type = "io.containerd.runsc.v1"

 '

sudo systemctl restart containerd

sudo sysctl -w net.bridge.bridge-nf-call-iptables=1 
