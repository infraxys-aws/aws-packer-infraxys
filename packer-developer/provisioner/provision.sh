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

sudo -- sh -c 'export DEBIAN_FRONTEND=noninteractive;
apt-get -qq -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade;
cd /opt/infraxys/bin;

. ./variables && docker-compose -f stack.yml pull;
./up.sh db; # first let the database initialize

docker pull quay.io/jeroenmanders/infraxys-runner:$VERSION;
docker pull quay.io/jeroenmanders/infraxys-provisioning-server:ubuntu-full-18.04-latest;

echo "Setting ubuntu-user password to infraxys.";
echo "infraxys\ninfraxys" | passwd ubuntu

curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
add-apt-repository "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main"

echo "Updating packages.";
apt-get -qq update;
echo "Installing lxde.";
apt-get -qq -y install lxde >/dev/null; # this otherwise generates way too much logging
echo "Installing Remote Desktop.";
apt-get -qq -y install xrdp;

echo "Installing Google Chrome".;
apt-get -qq -y install google-chrome-stable;
sed -i "s/.*PasswordAuthentication.*/PasswordAuthentication yes/g" /etc/ssh/sshd_config;

mkdir -p ~ubuntu/Desktop
cat << EOF > ~ubuntu/Desktop/GoogleChrome
[Desktop Entry]
Name=Google Chrome
Exec=/usr/bin/google-chrome-stable https://localhost https://infraxys.io
StartupNotify=true
Terminal=false
Icon=google-chrome
Type=Application
EOF

'

echo "AMI provisioning done.";