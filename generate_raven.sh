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
ceph0=$(rvn ip ceph0)
ceph1=$(rvn ip ceph1)
ceph2=$(rvn ip ceph2)

echo "" > raven
echo "# auto generated file: raven" >> raven
echo "" >> raven
echo "[deploy]" >> raven
echo "$ceph0" >> raven
echo "$ceph1" >> raven
echo "$ceph2" >> raven
echo "" >> raven
echo "[admin]" >> raven
echo "$admin" >> raven
echo "" >> raven
echo "[local]" >> raven
echo "localhost" >> raven

