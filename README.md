# Ceph Test

Built for a standalone environment to test building a ceph deployment using [raven](https://gitlab.com/rygoo/raven) and [ansible](https://www.ansible.com/).

## Building

`./build.sh`

### Expanding

If you want to build on this topology these are the steps to help:

1. modify `model.js` to add the new nodes in the topology.  Make sure that beyond creating the new device, that you also add the Links to connect them.
2. modify `config/switch1.conf` to add additional ports to the switch to support the new nodes/Links
3. modify `generate_disks.sh` to add any additional disks to the nodes as given in `model.js`
4. modify `generate_raven.sh` to add the names of the new nodes
5. modify `install_ansible` to add the names of the new nodes

## Scripts:

`./build.sh`: Wrapper for all the scripts to get the topology from nothing - to ansible ready
`./generate_disks.sh`: creates the qemu qcow2 disks for the ceph OSD nodes
`./generate_raven.sh`: creates the ansible inventory file
`./install_ansible.sh`: installs ansible + public key to all nodes
