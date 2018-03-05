#!/bin/bash
cd $1
echo 10 > /tmp/${2}_dep
DIRECTORY="/var/www"
if [ ! -d "$DIRECTORY" ]; then
  echo "Création du home www-data pour npm"
  sudo mkdir $DIRECTORY
fi
sudo chown -R www-data $DIRECTORY
echo 20 > /tmp/${2}_dep
if [ -x /usr/bin/nodejs ]; then
  actual=`nodejs -v | awk -F v '{ print $2 }' | awk -F . '{ print $1 }'`;
  echo "Version actuelle : ${actual}"
else
  actual=0;
  echo "Nodejs non installé"
fi


if [[ $actual -ge 8 ]]
then
  echo "Ok, version suffisante";
else
  echo "KO, version obsolète à upgrader";
  echo "Suppression du Nodejs existant et installation du paquet recommandé"
  sudo apt-get -y --purge autoremove nodejs npm
  arch=`arch`;
  echo 30 > /tmp/${2}_dep
  if [[ $arch == "armv6l" ]]
  then
    echo "Raspberry 1 détecté, utilisation du paquet pour armv6"
    sudo rm /etc/apt/sources.list.d/nodesource.list
    wget http://node-arm.herokuapp.com/node_latest_armhf.deb
    sudo dpkg -i node_latest_armhf.deb
    sudo ln -s /usr/local/bin/node /usr/local/bin/nodejs
    rm node_latest_armhf.deb
  else
    echo "Utilisation du dépot officiel"
    curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
    sudo apt-get install -y nodejs
  fi
  new=`nodejs -v`;
  echo "Version actuelle : ${new}"
fi

echo 70 > /tmp/${2}_dep

sudo rm -rf node_modules

echo 80 > /tmp/${2}_dep
npm install
sudo chown -R www-data node_modules
