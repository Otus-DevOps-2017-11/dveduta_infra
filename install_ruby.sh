#!/bin/bash

sudo apt update
sudo apt install -y ruby-full ruby-bundler buildessential

ruby -v
bundler -v
