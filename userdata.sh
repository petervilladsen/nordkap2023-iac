#!/bin/bash
sudo yum update -y &&
sudo amazon-linux-extras install nginx1.12 -y
sudo service nginx restart

# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
. ~/.nvm/nvm.sh
nvm install --lts
node -e "console.log('Running Node.js ' + process.version)"