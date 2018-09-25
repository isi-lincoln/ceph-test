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
  dd if=/dev/zero of=$storage/$i.img bs=1024 count=1024x1024x$disk_size > /dev/null
  parted -s $storage/$i.img mklabel gpt mkpart primary ext4 0% 100% name 1 test
  losetup -v -P -f $storage/$i.img
  loop_dev=$(losetup -a | grep $i.img | cut -d ':' -f 1)
  echo "$i: Creating Filesystem"
  if mke2fs -t ext4 ${loop_dev}p1 > /dev/null; then
    losetup -d $loop_dev
    echo "$i: Converting to Qcow2"
    if qemu-img convert -f raw -O qcow2 $storage/$i.img $storage/$i; then
      rm -rf $storage/$i.img
    else
      echo "Failed somewhere"
      exit 1
    fi
  else
    echo "Failed somewhere"
    exit 1
  fi
done
