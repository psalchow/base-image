FROM debian:jessie-backports
MAINTAINER Martin Verspai martin.verspai@iteratec.de

EXPOSE 22 8080 9990

# Adding users for maintenance
RUN useradd -ms /bin/bash jboss
RUN useradd -ms /bin/bash -G jboss publisher

# Create deploy directories
RUN mkdir -p /opt/jdk
RUN mkdir -p /opt/jboss
RUN mkdir -p /var/run/sshd
RUN mkdir -p /var/log/wildfly

# Download and configure required software
RUN apt-get update
RUN apt-get -y install wget openssh-server supervisor
RUN wget --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u51-b16/jdk-8u51-linux-x64.tar.gz
RUN wget http://download.jboss.org/wildfly/8.2.1.Final/wildfly-8.2.1.Final.tar.gz
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ADD sshd.conf /etc/supervisor/conf.d/sshd.conf
ADD wildfly.conf /etc/supervisor/conf.d/wildfly.conf
ADD supervisord.conf /etc/supervisor/supervisord.conf

RUN tar -zxf jdk-8u51-linux-x64.tar.gz -C /opt/jdk
RUN tar -zxf wildfly-8.2.1.Final.tar.gz -C /opt/jboss

RUN update-alternatives --install /usr/bin/java java /opt/jdk/jdk1.8.0_51/bin/java 100
ADD sqljdbc41.jar /opt/jboss/wildfly-8.2.1.Final/standalone/deployments/
RUN touch /opt/jboss/wildfly-8.2.1.Final/standalone/deployments/sqljdbc41.jar.dodeploy

# Cleaning up unused files
RUN rm jdk-8u51-linux-x64.tar.gz
RUN rm wildfly-8.2.1.Final.tar.gz
RUN apt-get -y remove wget
RUN apt-get -y autoremove
RUN apt-get clean

# Setting appropriate user permissions
RUN chown -R jboss:jboss /opt/jboss
RUN chown -R jboss:jboss /var/log/wildfly

CMD supervisord -n