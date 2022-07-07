FROM rockylinux:8

# Kudos to Hiroki Takeyama : https://github.com/takeyamajp/docker-rocky-sshd

# Update Rocky to the latest version
RUN dnf update -y && dnf upgrade --refresh -y

# Create a user "Ansible" for the container
RUN useradd -m -s /bin/bash Ansible

# Install and setup sshd
RUN dnf -y install openssh-server openssh-clients; \
    sed -i 's/^\(UsePAM yes\)/# \1/' /etc/ssh/sshd_config; \
    ssh-keygen -q -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N '' && \
    ssh-keygen -q -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N '' && \
    ssh-keygen -t dsa -f /etc/ssh/ssh_host_ed25519_key  -N ''; \
    dnf clean all;

# Setup the SSH key for Ansible
#COPY ssh/ansible.pub /home/Ansible/.ssh/authorized_keys

# Entrypoint
RUN { \
    echo '#!/bin/bash -eu'; \
    echo 'ln -fs /usr/share/zoneinfo/${TIMEZONE} /etc/localtime'; \
    echo 'echo "root:${ROOT_PASSWORD}" | chpasswd'; \
    echo 'exec "$@"'; \
    } > /usr/local/bin/entry_point.sh; \
    chmod +x /usr/local/bin/entry_point.sh;

ENV TIMEZONE Europe/Paris

ENV ROOT_PASSWORD rockylinux

# Disable root login and password authentication
RUN sed -i -E 's/#?PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config && sed -i -E 's/#?PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

EXPOSE 22

ENTRYPOINT ["entry_point.sh"]
CMD ["/usr/sbin/sshd", "-D", "-e"]