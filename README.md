rvn build
rvn deploy
rvn pingwait server
rvn configure
./generate_raven.sh
./install_ansible.sh

ansible-playbook -i raven ceph.yml
