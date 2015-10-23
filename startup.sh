#!/bin/bash

export JAVA_OPTS="-Xms256m -Xmx1024m -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -XX:+CMSPermGenSweepingEnabled -Djava.net.preferIPv4Stack=true"

/opt/jboss/wildfly/bin/standalone.sh