#
# Nutch
# Debian:wheezy
# docker build -t meabed/elasticsearch:latest .
#
# sudo sysctl -w vm.max_map_count=262144
# echo "vm.max_map_count=262144" >> /etc/sysctl.conf

FROM debian:wheezy
MAINTAINER Mohamed Meabed "mo.meabed@gmail.com"

USER root
ENV DEBIAN_FRONTEND noninteractive

# Download and Install JDK / Hadoop
ENV JDK_VERSION 7

ENV ES_VERSION 1.3.2

# install dev tools
RUN apt-get update
RUN apt-get install -y apt-utils curl tar openssh-server openssh-client rsync vim lsof

# passwordless ssh
RUN rm /etc/ssh/ssh_host_dsa_key /etc/ssh/ssh_host_rsa_key

RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa

RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys


# java
RUN apt-get install -y openjdk-$JDK_VERSION-jre-headless
#tomcat
#RUN apt-get install -y tomcat7 tomcat7-admin

ENV JAVA_HOME /usr/lib/jvm/java-$JDK_VERSION-openjdk-amd64
ENV PATH $PATH:$JAVA_HOME/bin

#Download nutch

RUN mkdir -p /opt/downloads && cd /opt/downloads && curl -SsfLO "https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-$ES_VERSION.deb"
RUN dpkg -i /opt/downloads/elasticsearch-$ES_VERSION.deb

ENV ES_LOG_DIR /var/log/elasticsearch
ENV ES_DATE_DIR /var/lib/elasticsearch
ENV HOME /root

RUN /usr/share/elasticsearch/bin/plugin -install royrusso/elasticsearch-HQ
RUN /usr/share/elasticsearch/bin/plugin -install lmenezes/elasticsearch-kopf

RUN sed -i '/sysctl -q -w vm.max_map_count/ s/^#*/true\n#/' /etc/init.d/elasticsearch

RUN service ssh start && service elasticsearch start

ADD bootstrap.sh /etc/bootstrap.sh
RUN chown root:root /etc/bootstrap.sh
RUN chmod 700 /etc/bootstrap.sh

CMD ["/etc/bootstrap.sh", "-d"]


# Expose ports.
#   - 9200: HTTP
#   - 9300: transport
EXPOSE 9200
EXPOSE 9300


