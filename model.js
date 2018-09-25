
cephs = {
    node: Range(4).map(i => Client('ceph'+i))
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

// use the raven image for fedora
server = {
  name: 'server',
  image: 'ubuntu-1604',
  cpu: { cores: 2 },
  memory: { capacity: GB(4) },
}

topo = {
  name: 'sled-basic',
  nodes: [...cephs.node, server],
  switches: [switch1],
  links: [
    ...cephs.node.map(x => Link(x.name, 0, 'switch1', ports.switch1++)),
    ...cephs.node.map(x => Link(x.name, 1, 'switch1', ports.switch1++)),
    Link('server', 0, 'switch1', ports.switch1++),
    Link('server', 1, 'switch1', ports.switch1++)
  ]
}

function Client(nameIn) {
    return ceph = {
      name: nameIn,
      image: 'ubuntu-1604',
      cpu: { cores: 2 },
      memory: { capacity: GB(4) },
      disks: [
        {
          source: env.PWD + "/storage/" + nameIn,
          dev: "vdb",
          bus: "virtio",
        },
      ],
    };
}
