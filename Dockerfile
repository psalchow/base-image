FROM debian:jessie-backports
MAINTAINER Martin Verspai martin.verspai@iteratec.de

EXPOSE 8080 9990

# Create deploy directories
RUN mkdir -p /opt/oracle && \
    mkdir -p /opt/jboss && \
    mkdir -p /var/log/wildfly && \
    mkdir -p /opt/share

# Download and configure required software
RUN apt-get update && apt-get -y install wget
RUN wget --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u102-b14/jdk-8u102-linux-x64.tar.gz
RUN wget http://download.jboss.org/wildfly/8.2.1.Final/wildfly-8.2.1.Final.tar.gz

RUN tar -zxf jdk-8u102-linux-x64.tar.gz -C /opt/oracle
RUN tar -zxf wildfly-8.2.1.Final.tar.gz -C /opt/jboss

RUN ln -s /opt/oracle/jdk1.8.0_102 /opt/oracle/jdk
RUN ln -s /opt/jboss/wildfly-8.2.1.Final /opt/jboss/wildfly

RUN update-alternatives --install /usr/bin/java java /opt/oracle/jdk/bin/java 100

ADD sqljdbc41.jar /opt/jboss/wildfly/standalone/deployments/
ADD startup.sh /opt/jboss/startup.sh
ADD additionalSystemProperties.properties /opt/jboss/

# Cleaning up unused files
RUN rm jdk-8u102-linux-x64.tar.gz
RUN rm wildfly-8.2.1.Final.tar.gz
RUN apt-get -y remove wget
RUN apt-get -y autoremove
RUN apt-get clean

# Adding users for maintenance
RUN useradd -d /opt/jboss -s /bin/bash jboss

# Setting appropriate user permissions and deployabled
RUN chown -R jboss:jboss /opt/jboss && \
    chmod g+w /opt/jboss/wildfly/standalone/deployments && \
    chown -R jboss:jboss /opt/share && \
    chmod -R 777 /opt/share && \
    chown -R jboss:jboss /var/log/wildfly && \
    chmod u+x /opt/jboss/startup.sh

USER jboss

CMD /opt/jboss/startup.sh
