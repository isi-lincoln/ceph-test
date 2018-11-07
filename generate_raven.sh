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

yaml () {
	str=""
	for i in "$@"
	do
		str+=$(printf "%s hostname=%s%s" "$(rvn ip $i)" "$i" "\n")
	done
	echo -e $str >> raven
}

yamlFedora () {
	str=""
	for i in "$@"
	do
		str+=$(printf "%s hostname=%s ansible_python_interpreter=/usr/bin/python3%s" "$(rvn ip $i)" "$i" "\n")
	done
	echo -e $str >> raven
}

hosts=( $(rvn status 2>&1 | grep "\s\s" | sed 's/^.*msg=//g' | sed 's/\s\+/ /g' | cut -d ' ' -f 2 | sort) )
cephs=()
admin=()
client=()
commander=()
driver=()
database=()

#echo $hosts
for i in "${hosts[@]}"
do
	if [[ $i = *"ceph"* ]]; then
		cephs+=($i)
	fi
	if [[ $i = *"server"* ]]; then
		server+=($i)
	fi
	if [[ $i = *"client"* ]]; then
		client+=($i)
	fi
	if [[ $i = *"commander"* ]]; then
		commander+=($i)
	fi
	if [[ $i = *"driver"* ]]; then
		driver+=($i)
	fi
	if [[ $i = *"database"* ]]; then
		database+=($i)
	fi
done

echo "# auto generated file: raven" > raven

echo "[deploy]" >> raven
yamlFedora ${cephs[@]}

# minimum 3 monitors
echo "[monitors]" >> raven
yamlFedora ${cephs[@]:0:3}

echo "[mds]" >> raven
mds=("${cephs[0]}")
mds=("${mds[@]} ${cephs[-1]}")
yamlFedora $mds

echo "[rgw]" >> raven
rgw=("${cephs[-1]}")
rgw=("${rgw[@]} ${cephs[0]}")
yamlFedora $rgw

echo "[mgr]" >> raven
mgr=("${cephs[1]}")
mgr=("${mgr[@]} ${cephs[2]}")
yamlFedora $mgr

echo "[admin]" >> raven
yamlFedora $server

echo "[clients]" >> raven
yamlFedora $client

echo "[commander]" >> raven
yamlFedora $commander

echo "[driver]" >> raven
yamlFedora $driver

echo "[database]" >> raven
yamlFedora $database

echo "[site:children]" >> raven
echo "commander" >> raven
echo "database" >> raven
echo "driver" >> raven
echo "" >> raven

echo "[nodes:children]" >> raven
echo "clients" >> raven
echo "admin" >> raven
echo "deploy" >> raven
echo "" >> raven

echo "[deploy:vars]" >> raven
echo "drives=\"['/dev/vdb', '/dev/vdc', '/dev/vdd', '/dev/vde', '/dev/vdf', '/dev/vdg', '/dev/vdh', '/dev/vdi']\"" >> raven
echo "" >> raven

echo "[all:vars]" >> raven
echo "ansible_ssh_private_key_file=roles/common/files/keys/ansible_key" >> raven
