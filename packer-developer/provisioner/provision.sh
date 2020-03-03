#!/usr/bin/env bash

set -eo pipefail;

#echo "Change ssh config"
#sudo cp sshd_config /etc/ssh/sshd_config;

initial_dir="$(pwd)";
export INFRAXYS_ROOT_DIR="/opt/infraxys";

VERSION="$(cat VERSION)";
IMAGE="quay.io/jeroenmanders/infraxys-developer-installer:$VERSION";

sudo mkdir -p "$INFRAXYS_ROOT_DIR/data/mysql";

sudo chown -R 2000:2000 "$INFRAXYS_ROOT_DIR";
sudo chmod -R a+w "$INFRAXYS_ROOT_DIR";

echo "Creating network 'infraxys-run'."
sudo docker network create -d bridge -o "com.docker.network.bridge.name"="infraxys-run0" infraxys-run;

echo "Launching installer now";

username="$(id -un)";
groupname="$(id -gn)";
export INFRAXYS_USERNAME="$username"
export INFRAXYS_FULLNAME="Developer"
export INFRAXYS_PORT="443";

sudo docker pull $IMAGE;
sudo docker run -i --rm \
  -e "VERSION=$VERSION" \
  -e "INFRAXYS_ROOT_DIR=$INFRAXYS_ROOT_DIR" \
  -e "INSTALL_MODE=LINUX" \
  -e "INFRAXYS_PORT=$INFRAXYS_PORT" \
  -e "INFRAXYS_USERNAME=$INFRAXYS_USERNAME" \
  -e "INFRAXYS_FULLNAME=$INFRAXYS_FULLNAME" \
  -v "$INFRAXYS_ROOT_DIR":/infraxys-root:rw \
  $IMAGE

  echo "Setting owner of Infraxys files to $username:$groupname";
  sudo chown -R "$username":"$groupname" "$INFRAXYS_ROOT_DIR";

cd "$INFRAXYS_ROOT_DIR/bin";

sudo -- sh -c '. ./variables && docker-compose -f stack.yml pull';


# Do not install Ubuntu Desktop because it disabled network access somehow

#
# echo "Retrieving localhost certificate.";
# sudo docker cp infraxys-developer-web:/infraxys/certs/localhost.crt .;
#
# echo "Copying the localhost certificate to the ca-certificates directory.";
# sudo mv localhost.crt /usr/local/share/ca-certificates/infraxys-localhost.crt;
# sudo update-ca-certificates;
#
# echo "Enabling password authentication for the UI.";
# sudo sed -i 's/.*PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config;
#
# cd "$initial_dir"
# echo "Installing Ubuntu Desktop and tightvncserver";
# sudo -- sh -c 'DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade;
# apt -qq update
# #apt -qq -y install ubuntu-desktop
# apt -qq -y install xfce4 xfce4-goodies
# apt -qq -y install tightvncserver
# '
#
# echo "Setting ubuntu-user password to 'infraxys'.";
# echo -e "infraxys\ninfraxys" | sudo passwd ubuntu
#
# echo "Setting vnc-password to 'infraxys'.";
# #sudo -- sh -c '
# mkdir -p ~/.vnc;
# echo "infraxys\ninfraxys" | vncpasswd -f > ~/.vnc/passwd;
# chmod 0600 ~/.vnc/passwd;
# #'
#
# sudo mv xstartup ~/.vnc/xstartup;
# sudo chmod +x ~/.vnc/xstartup;
# sudo cp vncserver.service /etc/systemd/system/vncserver@.service
#
