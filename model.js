cephs = {
    node: Range(4).map(i => Ceph('ceph'+i))
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

server = {
  name: 'server',
  image: 'ubuntu-1604',
  cpu: { cores: 2 },
  memory: { capacity: GB(4) },
}

client = {
  name: 'client',
  image: 'ubuntu-1604',
  cpu: { cores: 2 },
  memory: { capacity: GB(4) },
}

topo = {
  name: 'ceph-test',
  nodes: [...cephs.node, client, server],
  switches: [switch1],
  links: [
    ...cephs.node.map(x => Link(x.name, 0, 'switch1', ports.switch1++)),
    ...cephs.node.map(x => Link(x.name, 1, 'switch1', ports.switch1++)),
    Link('server', 0, 'switch1', ports.switch1++),
    Link('server', 1, 'switch1', ports.switch1++),
    Link('client', 0, 'switch1', ports.switch1++),
    Link('client', 1, 'switch1', ports.switch1++),
  ]
}

function Ceph(nameIn) {
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
