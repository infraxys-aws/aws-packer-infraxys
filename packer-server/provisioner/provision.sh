#!/usr/bin/env bash

set -eo pipefail;

echo "Creating directory /opt/infraxys";
sudo mkdir -p /opt/infraxys;
sudo chown ubuntu:ubuntu /opt/infraxys;
sudo mv opt/infraxys/* /opt/infraxys/;

#echo "Creating directory /opt/infraxys-provisioning-server";
#sudo mkdir -p /opt/infraxys-provisioning-server/;
#sudo mv opt/infraxys-provisioning-server/* /opt/infraxys-provisioning-server/;
sudo mkdir -p /opt/infraxys/logs/fluentd;
sudo chown ubuntu:ubuntu /opt/infraxys/logs/fluentd;

sudo mkdir /opt/infraxys/data;
sudo mkdir /opt/infraxys/data/vault;
sudo mkdir /opt/infraxys/data/mysql;

sudo cp *_VERSION /opt/infraxys/config/vars/

echo "Pulling Docker images"
cd /opt/infraxys/docker/infraxys;
sudo ./pull.sh;

echo "Creating Docker networks";
sudo docker network create -d bridge -o "com.docker.network.bridge.name"="infraxys-vault0" infraxys-vault;
sudo docker network create -d bridge -o "com.docker.network.bridge.name"="infraxys-admin0" infraxys-admin;
sudo docker network create -d bridge -o "com.docker.network.bridge.name"="infraxys-db0" infraxys-db;
sudo docker network create -d bridge -o "com.docker.network.bridge.name"="infraxys-log0" infraxys-log;
sudo docker network create -d bridge -o "com.docker.network.bridge.name"="infraxys-app0" infraxys-app;
sudo docker network create -d bridge -o "com.docker.network.bridge.name"="infraxys-oauth2" infraxys-oauth2;
sudo docker network create -d bridge -o "com.docker.network.bridge.name"="infraxys-run0" infraxys-run;
