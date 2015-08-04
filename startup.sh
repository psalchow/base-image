#!/bin/bash

export JAVA_OPTS="-Xms256m -Xmx1024m -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -XX:+CMSPermGenSweepingEnabled -Djava.net.preferIPv4Stack=true"

if [ -n "$PASS" ]
then
        echo publisher:$PASS | chpasswd
        echo "Changed password to: $PASS"
fi

if [ -n "$ENV" ]
then
        cp /opt/jboss/configuration/standalone_$ENV.xml /opt/jboss/wildfly/standalone/configuration/standalone.xml
        echo "Copied standalone_$ENV.xml to configuration folder"
fi

supervisord -n