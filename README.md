# Ceph Test

Built for a standalone environment to test building a ceph deployment using [raven](https://gitlab.com/rygoo/raven) and [ansible](https://www.ansible.com/).

## Building

0. `./generate_disks`  # build osds - Requires 80GB of storage
1. `rvn build`  # build the raven topology
2. `rvn deploy`  # deploy libvirt instances
3. `rvn pingwait server`  # wait until server is reachable
4. `rvn configure`  # configure each node (ip address, hostnames)
5. `./generate_raven.sh`  # create the ansible inventory file
6. `./install_ansible.sh`  # install ansible across all the nodes
7. `ansible-playbook -i raven ceph.yml`  # run the ceph configuration
