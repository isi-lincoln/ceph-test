

ceph_nodes=('ceph0' 'ceph1' 'ceph2' 'ceph3')

for i in "${ceph_nodes[@]}"
do
  echo "~~~~~~~~~~~~~~"
  echo "$i: Creating Image"
  echo "~~~~~~~~~~~~~~"
  dd if=/dev/zero of=$i.img bs=1024 count=1024x1024x2 > /dev/null
  parted -s $i.img mklabel gpt mkpart primary ext4 0% 100% name 1 test
  losetup -v -P -f $i.img
  loop_dev=$(losetup -a | grep $i.img | cut -d ':' -f 1)
  echo "$i: Creating Filesystem"
  if mke2fs -t ext4 ${loop_dev}p1 > /dev/null; then
    losetup -d $loop_dev
    echo "$i: Converting to Qcow2"
    if qemu-img convert -f raw -O qcow2 $i.img $i; then
      rm -rf $i.img
    else
      echo "Failed somewhere"
      exit 1
    fi
  else
    echo "Failed somewhere"
    exit 1
  fi
done
