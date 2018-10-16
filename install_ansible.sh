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

# all the raven nodes except the switches get ansible
hosts=( $(rvn status 2>&1 | grep "\s\s" | sed 's/^.*msg=//g' | sed 's/\s\+/ /g' | cut -d ' ' -f 2 | sort | grep -v "switch") )
#ansible_cmd1="sudo DEBIAN_FRONTEND=noninteractive apt-get update > /dev/null"
#ansible_cmd2="sudo DEBIAN_FRONTEND=noninteractive apt-get install -qqy ansible > /dev/null"
ansible_cmd1="sudo dnf update -y"
ansible_cmd2="sudo dnf install -y ansible > /dev/null"
death_to_apt='sudo kill -9 \`ps aux | grep apt | grep -v lock | grep -v grep | sed \"s/\s\+/ /g\" | cut -d \" \" -f 2\`'
create_dir="sudo mkdir -p /root/.ssh/"
chmod_dir="sudo chmod 700 /root/.ssh/"
pubkey=$(cat roles/common/files/keys/ansible_key.pub)
add_key="sudo bash -c 'echo $pubkey >> /root/.ssh/authorized_keys'"
timer=.5

# TODO: uname -a | grep -i ubuntu
# check os version to apply correct package management

prep_host () {
    # install ansible
    echo "$2: * Killing all the Apt Stuff"
    # kill update.daily
    eval $(printf "%s \"%s\"" "$1" "$death_to_apt")
    sleep $timer
    # kill install
    eval $(printf "%s \"%s\"" "$1" "$death_to_apt")
}

do_install () {
    echo "$2: * Installing Ansible"
    eval $(printf "%s \"%s\"" "$1" "$ansible_cmd1")
    eval $(printf "%s \"%s\"" "$1" "$ansible_cmd2")
    # install public key for ansible as root
    echo "$2: * Adding Public Keys"
    eval $(printf "%s \"%s\"" "$1" "$create_dir")
    eval $(printf "%s \"%s\"" "$1" "$chmod_dir")
    eval $(printf "%s \"%s\"" "$1" "$add_key")
}

pid_list=()
for i in "${hosts[@]}"
do
	host=$(rvn ssh $i)
	do_install "${host}" $i &
	pid_list+=($!)
done
for i in "${pid_list[@]}"
do
	wait $i
done
