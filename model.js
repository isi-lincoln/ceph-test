cephs = {
    node: Range(4).map(i => Ceph('ceph'+i))
}

cephTestMount = ["client"]
cephTest = ["server"]
merge = ["driver", "commander", "database"]

infra = {
    mergeNodes: Range(merge.length).map(i => Node(merge[i])),
    cephMNodes: Range(cephTest.length).map(i => NodeMount(cephTestMount[i])),
    cephNodes: Range(cephTest.length).map(i => Node(cephTest[i])),
}

switch1 = {
    'name': 'switch1',
    'image': 'cumulusvx-3.5',
    'os': 'linux',
    'cpu': { 'cores': 1 },
    'memory': { 'capacity': GB(1) },
}

ports = {
    switch1: 1,
}

topo = {
  name: 'ceph-test',
  nodes: [...cephs.node, ...infra.cephNodes,  ...infra.cephMNodes, ...infra.mergeNodes],
  switches: [switch1],
  links: [
    ...cephs.node.map(x => Link(x.name, 0, 'switch1', ports.switch1++)),
    ...cephs.node.map(x => Link(x.name, 1, 'switch1', ports.switch1++)),
    ...infra.mergeNodes.map(x => Link(x.name, 0, 'switch1', ports.switch1++)),
    ...infra.mergeNodes.map(x => Link(x.name, 1, 'switch1', ports.switch1++)),
    ...infra.cephNodes.map(x => Link(x.name, 0, 'switch1', ports.switch1++)),
    ...infra.cephNodes.map(x => Link(x.name, 1, 'switch1', ports.switch1++)),
    ...infra.cephMNodes.map(x => Link(x.name, 0, 'switch1', ports.switch1++)),
    ...infra.cephMNodes.map(x => Link(x.name, 1, 'switch1', ports.switch1++)),
  ]
}



function cephDisks(nameIn) {
	disks = [];
	for (i = 0; i < 8; i++) {
		disks.push({
			size: "20G",
			dev: "vd" + String.fromCharCode('b'.charCodeAt() + i) ,
			bus: "virtio",
		})
	}
	return disks
}

function Ceph(nameIn) {
    return ceph = {
      name: nameIn,
      image: 'fedora-28',
      cpu: { cores: 2 },
      memory: { capacity: GB(4) },
      disks: cephDisks(nameIn),
    };
}

function Node(nameIn) {
    return ceph = {
      name: nameIn,
      image: 'fedora-28',
      cpu: { cores: 2 },
      memory: { capacity: GB(4) },
    };
}


function NodeMount(nameIn) {
    return ceph = {
      name: nameIn,
      image: 'fedora-28',
      cpu: { cores: 2 },
      memory: { capacity: GB(4) },
      mounts: [
        // where code resides
        { source: '/home/lthurlow/go/src/gitlab.com/dcomptb/cogs', point: '/home/rvn/code' },
      ]
    };
}
