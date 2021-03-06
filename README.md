# Ceph Test

Built for a standalone environment to test building a ceph deployment using [raven](https://gitlab.com/rygoo/raven) and [ansible](https://www.ansible.com/).

## Building

`./build.sh`
`ansible-playbook -i raven ceph.yml`

### Expanding

If you want to build on this topology these are the steps to help:

1. modify `model.js` to add the new nodes in the topology.  Make sure that beyond creating the new device, that you also add the Links to connect them.
2. modify `config/switch1.conf` to add additional ports to the switch to support the new nodes/Links
4. modify `generate_raven.sh` to add new roles/names for your host

## Scripts:

`./build.sh`: Wrapper for all the scripts to get the topology from nothing - to ansible ready

`./generate_raven.sh`: creates the ansible inventory file

`./install_ansible.sh`: installs ansible + public key to all nodes
