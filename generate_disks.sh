#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "requires root access to mount- please sudo"
   exit 1
fi

# gigabytes
disk_size=20 # Unable to set partition 2's name to 'ceph journal' > 10gb, recommended 20gb
ceph_nodes=('ceph0' 'ceph1' 'ceph2' 'ceph3')
storage="storage"

mkdir -p "./$storage"

for i in "${ceph_nodes[@]}"
do
  echo "~~~~~~~~~~~~~~"
  echo "$i: Creating Image"
  echo "~~~~~~~~~~~~~~"
  qemu-img create -f qcow2 $storage/$i ${disk_size}G
done
