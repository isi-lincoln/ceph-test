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

hosts=('server' 'ceph0' 'ceph1' 'ceph2')
ansible_cmd="sudo apt-get -q update && sudo apt-get install -qqy ansible"
create_dir="sudo mkdir -p /root/.ssh/"
chmod_dir="sudo chmod 700 /root/.ssh/"
pubkey=$(cat keys/ceph_key.pub)
add_key="sudo bash -c 'echo $pubkey >> /root/.ssh/authorized_keys'"

for i in "${hosts[@]}"
do
    host=$(rvn ssh $i)
    # install ansible
    eval $(printf "%s \"%s\"" "$host" "$ansible_cmd")
    # install public key for ansible as root
    eval $(printf "%s \"%s\"" "$host" "$create_dir")
    eval $(printf "%s \"%s\"" "$host" "$chmod_dir")
    eval $(printf "%s \"%s\"" "$host" "$add_key")
done
