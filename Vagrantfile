# -*- mode: ruby -*-
# vi: set ft=ruby :

$bootstrap = <<SCRIPT
  export DEBIAN_FRONTEND=noninteractive
  sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
  sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
  echo "10.5.7.10 master" >> /etc/hosts
  echo "10.5.7.11 worker1" >> /etc/hosts
  echo "10.5.7.12 worker2" >> /etc/hosts
  echo 'root:r00tme' | chpasswd
  service ssh restart
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
  echo 'deb https://apt.kubernetes.io/ kubernetes-xenial main' >> /etc/apt/sources.list.d/kubernetes.list
  apt-get update && apt-get install -f --assume-yes apt-transport-https curl
  apt-get install -f --assume-yes kubelet kubeadm kubectl docker.io
  apt-mark hold kubelet kubeadm kubectl
  kubeadm config images pull
SCRIPT


$bootstrap_master = <<SCRIPT
  export DEBIAN_FRONTEND=noninteractive
  apt-get -f --assume-yes install sshpass
  ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa
  sshpass -p "r00tme" ssh-copy-id -o StrictHostKeyChecking=no root@worker1 > /dev/null 2>&1
  sshpass -p "r00tme" ssh-copy-id -o StrictHostKeyChecking=no root@worker2 > /dev/null 2>&1
  source /usr/share/bash-completion/bash_completion
  echo 'source <(kubectl completion bash)' >>~/.bashrc
  kubectl completion bash >/etc/bash_completion.d/kubectl
  wget -q https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml -O  /root/calico.yaml
  cat >> /root/init.sh <<-EOF
#!/bin/bash
kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=10.5.7.10
mkdir -p $HOME/.kube
cp /etc/kubernetes/admin.conf $HOME/.kube/config
kubectl apply -f https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml
patch < calico.patch
kubectl apply -f calico.yaml
EOF

  cat >> /root/calico.patch <<-EOF
--- calico.yaml       2019-04-25 10:54:26.719218000 +0000
+++ calico2.yaml      2019-04-25 10:52:11.959872000 +0000
@@ -262,6 +262,8 @@
             # Auto-detect the BGP IP address.
             - name: IP
               value: "autodetect"
+            - name: IP_AUTODETECTION_METHOD
+              value: interface=enp0s8
             # Enable IPIP
             - name: CALICO_IPV4POOL_IPIP
               value: "Always"
EOF
  chmod +x /root/init.sh
  git clone https://github.com/wiewioras/k8s-labs.git /root/
SCRIPT




Vagrant.configure("2") do |config|

  config.vm.provider "virtualbox" do |mem|
    mem.customize ["modifyvm", :id, "--memory", "2048"]
  end

  config.vm.define :worker1 do |worker1|
    worker1.vm.box = "ubuntu/xenial64"
    worker1.vm.network :private_network, ip: "10.5.7.11"
    worker1.vm.provider "virtualbox"
    worker1.vm.hostname = "worker1"
    worker1.vm.provision "shell", inline: $bootstrap, privileged: true
  end
  config.vm.define :worker2 do |worker2|
    worker2.vm.box = "ubuntu/xenial64"
    worker2.vm.network :private_network, ip: "10.5.7.12"
    worker2.vm.hostname = "worker2"
    worker2.vm.provider "virtualbox"
    worker2.vm.provision "shell", inline: $bootstrap, privileged: true
  end

  config.vm.define :master do |master|
    master.vm.box = "ubuntu/xenial64"
    master.vm.network :private_network, ip: "10.5.7.10"
    master.vm.hostname = "master"
    master.vm.provider "virtualbox"
    master.vm.provision "shell", inline: $bootstrap, privileged: true
    master.vm.provision "shell", inline: $bootstrap_master, privileged: true
  end
end

