FROM srv6d/ubuntu-systemd:22.04

RUN apt-get update && apt-get install -y openssh-server sudo
RUN mkdir /var/run/sshd

RUN useradd -m -s /bin/bash ansible
RUN echo "ansible ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN mkdir /home/ansible/.ssh
RUN ssh-keygen -t ed25519 -f /home/ansible/.ssh/id_ed25519 -N "" -C "ansible@docker-container"

RUN cp "/home/ansible/.ssh/id_ed25519.pub" "/home/ansible/.ssh/authorized_keys"


CMD ["/usr/sbin/sshd", "-D"]
