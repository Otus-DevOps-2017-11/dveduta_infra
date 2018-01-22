#!/bin/bash

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 
sudo bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list'
sudo apt update
sudo apt install -y ruby-full ruby-bundler build-essential mongodb-org

ruby -v
bundler -v

sudo systemctl enable mongod
sudo systemctl start mongod
sudo systemctl status mongod

cd ~

git clone https://github.com/Otus-DevOps-2017-11/reddit.git

cd reddit && bundle install && puma -d
