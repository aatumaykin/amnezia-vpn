#!/usr/bin/env bash

apt update && apt upgrade -y
apt install -y sudo wget curl ufw git

# Install Docker
sh -c "$(curl -fsSL https://get.docker.com/)"