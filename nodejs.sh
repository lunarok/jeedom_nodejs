#!/bin/bash
cd $1
if [ "$2" == *"dependancy" ]; then
  LOG=${2}
else
  LOG='/tmp/${2}_dep'
fi
echo 10 > $LOG
DIRECTORY="/var/www"
if [ ! -d "$DIRECTORY" ]; then
  echo "Création du home www-data pour npm"
  sudo mkdir $DIRECTORY
fi
sudo chown -R www-data $DIRECTORY
echo 20 > $LOG
if [ -x /usr/bin/nodejs ]; then
  actual=`nodejs -v | awk -F v '{ print $2 }' | awk -F . '{ print $1 }'`;
  echo "Version actuelle : ${actual}"
else
  actual=0;
  echo "Nodejs non installé"
fi

sudo apt-get update
sudo apt-get -y install lsb-release
release=$( lsb_release -c -s )
version=14

if [[ $actual -ge $version ]]
then
  echo "Ok, version suffisante";
else
  echo "KO, version obsolète à upgrader";
  echo "Suppression du Nodejs existant et installation du paquet recommandé"
  sudo apt-get -y --purge autoremove nodejs npm
  arch=`arch`;
  echo 30 > $LOG
  if [ "$arch" == "armv6l" ]
  then
    echo "Raspberry 1 détecté, utilisation du paquet pour armv6"
    sudo rm /etc/apt/sources.list.d/nodesource.list
    wget http://node-arm.herokuapp.com/node_latest_armhf.deb
    sudo dpkg -i node_latest_armhf.deb
    #sudo ln -s /usr/local/bin/node /usr/local/bin/nodejs
    rm node_latest_armhf.deb
  else
    echo "Utilisation du dépot officiel"
    curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
    sudo apt-get install -y nodejs
  fi
  sudo ln -s `which node` `which node`js
  new=`nodejs -v`;
  echo "Version actuelle : ${new}"
fi

echo 70 > $LOG

sudo rm -rf node_modules

echo 80 > $LOG
npm install
sudo chown -R www-data node_modules
