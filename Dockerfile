FROM python:3.7-slim-stretch

ADD . /app
WORKDIR /app

# install volvooncall
RUN set -x \
&& apt-get update \
&& apt-get -y --no-install-recommends install dumb-init libsodium18 \
&& apt-get -y autoremove \
&& apt-get -y clean \
&& rm -rf /var/lib/apt/lists/* \
&& rm -rf /tmp/* \
&& rm -rf /var/tmp/* \
#&& useradd -M --home-dir /app voc \
&& useradd -M --home-dir /app -rm -s /bin/bash -g root -G sudo -u 1000 voc
  ;
RUN pip --no-cache-dir --trusted-host pypi.org install --upgrade -r /app/requirements.txt pip coloredlogs libnacl \
  && pip install /app && rm -rf /app \
  ;

USER voc

# install SSH server for external access of docker container
RUN apt-get install -y openjdk-8-jdk-headless wget openssh-server tar vim
RUN echo “voc:passwort” | chpasswd
RUN sed -i ‘s/prohibit-password/yes/’ /etc/ssh/sshd_config
#ADD ssh.tar /root/
#RUN chown -R root:root /root/.ssh;chmod -R 700 /root/.ssh
RUN echo “StrictHostKeyChecking=no” >> /etc/ssh/ssh_config
RUN mkdir /var/run/sshd
#RUN apt install  openssh-server sudo -y
#RUN useradd -rm -d /home/ubuntu -s /bin/bash -g root -G sudo -u 1000 test 
#RUN echo 'test:test' | chpasswd
RUN service ssh start

EXPOSE 22
# start sshd daemon
CMD ["/usr/sbin/sshd","-D"]

ENTRYPOINT ["dumb-init", "--", "voc", "mqtt"]
