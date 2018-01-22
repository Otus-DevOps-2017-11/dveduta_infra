#!/bin/bash

cd ~

sudo mv puma.service /etc/systemd/system/puma.service
sudo systemctl daemon-reload
sudo systemctl enable puma.service

git clone https://github.com/Otus-DevOps-2017-11/reddit.git

cd reddit && bundle install


