#!/bin/bash
# Shell script to build and run the proxy server and validation server

cd analyticproxy-core
mvn clean package

cp -R target/analyticproxy-core-0.0.1-SNAPSHOT ../proxy-server/apache-tomcat-6.0.29/proxyWebapps/

cd ../proxy-server/apache-tomcat-6.0.29
bin/startup.sh && tail -f logs/catalina.out
