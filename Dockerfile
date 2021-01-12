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
# && useradd -M --home-dir /app voc \
  ;
RUN pip --no-cache-dir --trusted-host pypi.org install --upgrade -r /app/requirements.txt pip coloredlogs libnacl \
  && pip install /app && rm -rf /app \
  ;

#USER voc  

# install SSH server for external access of docker container
RUN apt install  openssh-server sudo -y
RUN useradd -rm -d /home/ubuntu -s /bin/bash -g root -G sudo -u 1000 test 
RUN echo 'test:test' | chpasswd
RUN service ssh start

EXPOSE 22
# start sshd daemon
CMD ["/usr/sbin/sshd","-D"]

ENTRYPOINT ["dumb-init", "--", "voc", "mqtt"]
