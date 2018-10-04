#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "requires root access to build - please sudo"
   exit 1
fi

echo "Cleaning Raven."
if rvn destroy; then
	echo "Raven destroyed"
else
	exit 1
fi
if rvn build; then
	echo "Built Raven Topology"
else
	exit 1
fi
if rvn deploy; then
	echo "Deployed Raven Topology"
else
	exit 1
fi
echo "Pinging nodes until topology is ready."
if rvn pingwait client server commander driver ceph0 ceph1 ceph2 ceph3 switch1; then
	echo "Raven Topology UP"
else
	exit 1
fi
echo "Configuring Raven Topology."
if rvn configure; then
	echo "Raven Topology configured"
else
	exit 1
fi
if ./generate_raven.sh; then
	echo "Generated Ansible Inventory File"
else
	exit 1
fi
echo "Installing Ansible + Updating Packages"
if ./install_ansible.sh; then
	echo "Installed Ansible"
else
	exit 1
fi
echo "Done."
