#!/bin/bash

set -e

RUNNER_DIR="${RUNNER_DIR:-/home/vagrant/actions-runner}"

# Updating packages
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get upgrade -y -qq

# Installing dependencies (curl, jq, Python, build-essential)
apt-get install -y -qq curl jq build-essential python3 python3-venv

# Installing Docker
curl -fsSL https://get.docker.com | sh
usermod -aG docker vagrant

# Skip if runner already extracted (idempotent)
if [ -f "$RUNNER_DIR/config.sh" ]; then
	exit 0
fi

# Downloading latest GitHub Actions runner
mkdir -p "$RUNNER_DIR"
cd "$RUNNER_DIR"

runner_plat=linux
runner_arch=x64
case "$(uname -m)" in aarch64 | arm64) runner_arch=arm64 ;; esac

latest_tag=$(curl -s 'https://api.github.com/repos/actions/runner/releases/latest' | jq -r '.tag_name')
latest_version="${latest_tag#v}"
runner_file="actions-runner-${runner_plat}-${runner_arch}-${latest_version}.tar.gz"
runner_url="https://github.com/actions/runner/releases/download/${latest_tag}/${runner_file}"

curl -sSL -o "$runner_file" "$runner_url"
tar xzf "$runner_file"
rm -f "$runner_file"

chown -R vagrant:vagrant "$RUNNER_DIR"
