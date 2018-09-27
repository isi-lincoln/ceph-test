#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "rvn requires root access - please sudo"
   exit 1
fi

if rvn ip server > /dev/null; then
    echo "Checking output..."
    response=$(rvn ip server | wc -m)
    # 8 because .... + 4 characters minimum
    if [[ "$response" -lt 8 ]]; then
	echo "Did not return valid ip, check 'rvn deploy/configure'"
	exit 1
    fi
else
    echo "Unable to run raven, confirm correct directory and 'rvn build'"
    exit 1
fi

admin=$(rvn ip server)
client=$(rvn ip client)
ceph0=$(rvn ip ceph0)
ceph1=$(rvn ip ceph1)
ceph2=$(rvn ip ceph2)
ceph3=$(rvn ip ceph3)

cat > raven << EOF
# auto generated file: raven

[deploy]
$ceph0 hostname=ceph0
$ceph1 hostname=ceph1
$ceph2 hostname=ceph2
$ceph3 hostname=ceph3

[admin]
$admin hostname=server

[clients]
$client hostname=client

[nodes:children]
clients
deploy

[all:vars]
ansible_ssh_private_key_file=roles/common/files/keys/ansible_key
EOF
