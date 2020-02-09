#!/usr/bin/env bash

echo "Starting GitHub webhook listener for this provisioning server.";
sudo bash -c "cd /opt/infraxys-provisioning-server/docker/webhook; ./up.sh;"