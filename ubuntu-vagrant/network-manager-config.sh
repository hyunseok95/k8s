sudo apt-get update
sudo apt-get install -y network-manager
sudo touch /run/NetworkManager/conf.d/10-globally-managed-devices.conf
sudo sed -i.bak 's/managed=false/managed=true/' /etc/NetworkManager/NetworkManager.conf
sudo systemctl restart NetworkManager

