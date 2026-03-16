#!/bin/bash

set -e

RUNNER_DIR="/home/vagrant/actions-runner"

echo "==============================================="
echo "   GitHub Self-Hosted Runner - Decommission"
echo "==============================================="
echo ""
echo "  In GitHub: Repo or Org ⇒ Settings ⇒ Actions ⇒ Runners"
echo "  Select the runner ⇒ Remove ⇒ copy the removal token."
echo ""

read -s -p "Removal token: " TOKEN
echo ""
if [ -z "$TOKEN" ]; then
	echo "Error: Token is required." >&2
	exit 1
fi

echo ""
echo "Stopping service, uninstalling, then removing runner from GitHub..."
vagrant ssh -c "cd $RUNNER_DIR && (sudo ./svc.sh stop 2>/dev/null || true) && (sudo ./svc.sh uninstall 2>/dev/null || true) && ./config.sh remove --token '$TOKEN'"

echo ""
echo "Runner decommissioned. Destroying VM..."
vagrant destroy -f

echo ""
echo "Done. Runner removed and VM destroyed."
