#FROM scratch
#ADD alpine-minirootfs-3.9.4-x86_64.tar.gz /
FROM alpine
RUN apk update && apk add bash ca-certificates wget openssl curl openssh openrc vim git mysql-client && update-ca-certificates;
RUN addgroup -S dev && adduser -S -G dev  -s /bin/bash dev; echo "dev:r00tme" | chpasswd; ssh-keygen -f /home/dev/ssh_host_rsa_key -N '' -t rsa; ssh-keygen -f /home/dev/ssh_host_dsa_key -N '' -t dsa; ssh-keygen -f /home/dev/ssh_host_ecdsa_key -N '' -t ecdsa -b 521; mkdir -p /home/dev/.ssh/keys; mkdir /home/dev/.kube
COPY sshd_config /etc/ssh/sshd_config 
COPY bastion_rsa.pub /home/dev/.ssh/authorized_keys
ADD https://storage.googleapis.com/kubernetes-release/release/v1.14.1/bin/linux/amd64/kubectl /usr/local/bin/kubectl
COPY dev.conf /home/dev/.kube/config
COPY ca.crt /home/dev/.kube/ca.crt
RUN rm -rf /var/cache/apk/*; chown -R dev:dev /home/dev; chmod 0600 /home/dev/.ssh/authorized_keys; chmod +x /usr/local/bin/kubectl; echo 'kubectl config set-cluster myapp --server="https://10.5.7.10:6443" --certificate-authority=/home/dev/.kube/ca.crt --embed-certs=true && kubectl config set-context dev --cluster=myapp --user=dev --namespace=myapp && kubectl config use-context dev' >> /home/dev/.bash_profile
EXPOSE 2200
CMD ["/usr/sbin/sshd","-D"]
