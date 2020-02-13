echo "Executing user-data script.";

ALL_IN_ONE="true";
if [ "$ALL_IN_ONE" == "false" ]; then
  echo "Generating ssh-key.";
  key_path="/opt/infraxys/upload";
  mkdir -p "$key_path";
  ssh-keygen -N "" -C "infraxys-app" -f "$key_path/id_rsa_provisioning_server"
  echo "Files under $key_path:";

  echo "Adding new ssh-key to authorized_keys of root"
  cat "$key_path/id_rsa_provisioning_server.pub" | sudo tee /root/.ssh/authorized_keys
  rm "$key_path/id_rsa_provisioning_server.pub";
fi;

# set password for Ubuntu because ssh won't work otherwise
echo "Generating password"
pwd="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)";
echo "Setting password"
echo "ubuntu:$pwd" | chpasswd;

echo "Starting initial Infraxys stack";
sudo bash -c "cd /opt/infraxys/docker/vault; ./up.sh;"
sudo bash -c "cd /opt/infraxys/docker/infraxys; ./start_db.sh;"
sudo bash -c "cd /opt/infraxys/docker/admin; ./up.sh;"

#rm -Rf /opt/infraxys/user_data;

if [ "$ALL_IN_ONE" == "false" ]; then
  if [ -f "/opt/infraxys-provisioning-server/user_data/setup.sh" ]; then
      /opt/infraxys-provisioning-server/user_data/setup.sh;
  fi;
fi;
