FROM debian:jessie-backports
MAINTAINER Martin Verspai martin.verspai@iteratec.de

EXPOSE 22 8080 9990

# Declare password variable for publisher
ENV PASS=secret

# Create deploy directories
RUN mkdir -p /opt/oracle
RUN mkdir -p /opt/jboss
RUN mkdir -p /var/run/sshd
RUN mkdir -p /var/log/wildfly

# Download and configure required software
RUN apt-get update && apt-get -y install wget openssh-server supervisor
RUN wget --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u51-b16/jdk-8u51-linux-x64.tar.gz
RUN wget http://download.jboss.org/wildfly/8.2.1.Final/wildfly-8.2.1.Final.tar.gz
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

RUN tar -zxf jdk-8u51-linux-x64.tar.gz -C /opt/oracle
RUN tar -zxf wildfly-8.2.1.Final.tar.gz -C /opt/jboss

RUN ln -s /opt/oracle/jdk1.8.0_51 /opt/oracle/jdk
RUN ln -s /opt/jboss/wildfly-8.2.1.Final /opt/jboss/wildfly

RUN update-alternatives --install /usr/bin/java java /opt/oracle/jdk/bin/java 100

ADD sshd.conf /etc/supervisor/conf.d/sshd.conf
ADD wildfly.conf /etc/supervisor/conf.d/wildfly.conf
ADD supervisord.conf /etc/supervisor/supervisord.conf
ADD startup.sh /root/startup.sh
ADD sqljdbc41.jar /opt/jboss/wildfly/standalone/deployments/

# Cleaning up unused files
RUN rm jdk-8u51-linux-x64.tar.gz
RUN rm wildfly-8.2.1.Final.tar.gz
RUN apt-get -y remove wget
RUN apt-get -y autoremove
RUN apt-get clean

# Adding users for maintenance
RUN useradd -d /opt/jboss -s /bin/bash jboss
RUN useradd -d /opt/jboss/wildfly/standalone/deployments -s /bin/bash -G jboss publisher

# Setting appropriate user permissions and deployabled
RUN touch /opt/jboss/wildfly/standalone/deployments/sqljdbc41.jar.dodeploy
RUN chown -R jboss:jboss /opt/jboss
RUN chmod g+w /opt/jboss/wildfly/standalone/deployments
RUN chown -R jboss:jboss /var/log/wildfly
RUN chmod o+x /root/startup.sh

CMD /root/startup.sh