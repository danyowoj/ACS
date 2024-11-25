FROM ubuntu:latest

RUN apt-get update && apt-get install -y \
    openssh-server \
    python3 \
    python3-pip \
    sudo

RUN useradd -m -s /bin/bash user && echo "user:password" | chpasswd \
    && mkdir /home/user/.ssh && chmod 700 /home/user/.ssh \
    && usermod -aG sudo user

COPY id_rsa.pub /home/user/.ssh/authorized_keys
RUN chmod 600 /home/user/.ssh/authorized_keys \
    && chown -R user:user /home/user/.ssh

RUN echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config \
    && echo "PermitRootLogin no" >> /etc/ssh/sshd_config \
    && echo "AllowUsers user" >> /etc/ssh/sshd_config

RUN mkdir /var/run/sshd
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
