FROM debian:jessie-backports
MAINTAINER Martin Verspai martin.verspai@iteratec.de

EXPOSE 8080 9990

# Create deploy directories
RUN mkdir -p /opt/oracle && \
    mkdir -p /opt/jboss && \
    mkdir -p /var/log/wildfly && \
    mkdir -p /opt/share

RUN apt-get update && apt-get -y install wget
RUN wget --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u121-b13/e9e7ea248e2c4826b92b3f075a80e441/jdk-8u121-linux-x64.tar.gz
RUN wget http://download.jboss.org/wildfly/10.1.0.Final/wildfly-10.1.0.Final.tar.gz

RUN tar -zxf jdk-8u121-linux-x64.tar.gz -C /opt/oracle
RUN tar -zxf wildfly-10.1.0.Final.tar.gz -C /opt/jboss

RUN ln -s /opt/oracle/jdk1.8.0_121 /opt/oracle/jdk
RUN ln -s /opt/jboss/wildfly-10.1.0.Final /opt/jboss/wildfly

RUN update-alternatives --install /usr/bin/java java /opt/oracle/jdk/bin/java 100

RUN mkdir -p /opt/jboss/wildfly/modules/system/layers/base/com/microsoft/sqlserver/main/
ADD module.xml /opt/jboss/wildfly/modules/system/layers/base/com/microsoft/sqlserver/main/
ADD mssql-jdbc-6.1.5.jre8-preview.jar /opt/jboss/wildfly/modules/system/layers/base/com/microsoft/sqlserver/main/
ADD startup.sh /opt/jboss/startup.sh

# Cleaning up unused files
RUN rm jdk-8u121-linux-x64.tar.gz
RUN rm wildfly-10.1.0.Final.tar.gz
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