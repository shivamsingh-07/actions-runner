#!/bin/bash

set -e

RUNNER_DIR="/home/vagrant/actions-runner"

echo "=================================================="
echo "  GitHub Self-Hosted Runner - Interactive Setup"
echo "=================================================="
echo ""

echo "Step 1: Starting Vagrant box and provisioning (packages + runner configuration)..."
vagrant up
echo ""

echo "Step 2: Configure the runner (registration token from GitHub)."
echo ""
echo "  In GitHub: Repo or Org → Settings → Actions → Runners → New self-hosted runner"
echo "  Copy the registration token shown there (it expires in ~1 hour)."
echo ""

read -p "Repository URL: " REPO_URL
REPO_URL="${REPO_URL// /}"
if [ -z "$REPO_URL" ]; then
	echo "Error: URL is required." >&2
	exit 1
fi
if [[ ! "$REPO_URL" =~ ^https?:// ]]; then
	echo "Error: URL should start with http:// or https://" >&2
	exit 1
fi

read -s -p "Registration token: " TOKEN
echo ""
if [ -z "$TOKEN" ]; then
	echo "Error: Token is required." >&2
	exit 1
fi

echo ""
read -p "Runner name (optional, press Enter for hostname): " RUNNER_NAME
RUNNER_NAME="${RUNNER_NAME:-}"

echo ""
echo "Step 3: Configuring runner in VM..."

if [ -n "$RUNNER_NAME" ]; then
	CONFIG_CMD="cd $RUNNER_DIR && ./config.sh --url '$REPO_URL' --token '$TOKEN' --name '$RUNNER_NAME' --unattended"
else
	CONFIG_CMD="cd $RUNNER_DIR && ./config.sh --url '$REPO_URL' --token '$TOKEN' --unattended"
fi

vagrant ssh -c "$CONFIG_CMD"

echo ""
echo "Runner configured successfully."

echo "Step 4: Installing and starting runner as a service..."
vagrant ssh -c "cd $RUNNER_DIR && sudo ./svc.sh install vagrant && sudo ./svc.sh start"
vagrant ssh -c "cd $RUNNER_DIR && sudo ./svc.sh status"
echo ""
echo "Runner is running as a systemd service and will start on boot."

echo ""
echo "Done. Check your repository Settings ⇒ Actions ⇒ Runners to see the new runner."
