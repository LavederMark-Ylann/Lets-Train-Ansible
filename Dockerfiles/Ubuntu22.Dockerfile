FROM ubuntu:22.04

# Update Ubuntu 20.04 to the latest version
RUN apt update -y && apt upgrade -y

# Create a user "Ansible" for the container
RUN useradd -m -s /bin/bash Ansible

# Install and setup sshd
RUN apt-get -y install openssh-server && sed -i 's/^\(UsePAM yes\)/# \1/' /etc/ssh/sshd_config && mkdir -p /run/sshd

# Entrypoint
RUN { \
    echo '#!/bin/bash -eu'; \
    echo 'ln -fs /usr/share/zoneinfo/${TIMEZONE} /etc/localtime'; \
    echo 'echo "root:${ROOT_PASSWORD}" | chpasswd'; \
    echo 'exec "$@"'; \
    } > /usr/local/bin/entry_point.sh; \
    chmod +x /usr/local/bin/entry_point.sh;

ENV TIMEZONE Europe/Paris

ENV ROOT_PASSWORD ubuntu20

# Disable root login and password authentication
RUN sed -i -E 's/#?PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config && sed -i -E 's/#?PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

EXPOSE 22

ENTRYPOINT ["entry_point.sh"]
CMD ["/usr/sbin/sshd", "-D", "-e"]