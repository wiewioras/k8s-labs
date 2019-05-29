#!/bin/bash
SCRIPTPATH=`dirname $(realpath $0)`

kubectl apply -f 9-users.yaml
kubeadm alpha kubeconfig user --client-name=dev --org=developers --apiserver-advertise-address 10.5.7.10 > /root/dev.conf
cp /root/dev.conf $SCRIPTPATH/alpinebastion/
cp /etc/kubernetes/pki/ca.crt $SCRIPTPATH/alpinebastion/


useradd -b /home -m -s /bin/bash -c "Our user" dev 
mkdir /home/dev/.kube
cp -p /root/dev.conf /home/dev/.kube/config
chown dev:dev -R /home/dev
echo 'dev:r00tme' | chpasswd
su - dev -c 'kubectl config set-cluster myapp --server="https://10.5.7.10:6443" --certificate-authority=/etc/kubernetes/pki/ca.crt --embed-certs=true && kubectl config set-context dev --cluster=myapp --user=dev --namespace=myapp && kubectl config use-context dev'
su - dev -c 'echo "Executing as user: $(whoami)" && echo "TEST: kubectl auth can-i create pod:" $(kubectl auth can-i create pod)'
