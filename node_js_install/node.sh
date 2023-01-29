#!/usr/bin/env bash
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
source ~/.nvm/nvm.sh
nvm --version
nvm install node --lts
node --version