local k = import 'github.com/jsonnet-libs/k8s-alpha/1.19/main.libsonnet';

local default_config = {
  image: error 'Must specify image',
  texture_version: error 'Must specify texture_version',
  uid: 1000,
  ports: [80, 443],
  update_interval: 3600,
  single_node: false,
  data_host_path: '/data/minecraft',
};

{
  new(opts):
    local config = default_config + opts;
    {
      Containerfile: (import 'containerfile.jsonnet').new(config),
      config_py:: |||
        import os
        worlds["world"] = "/data/world"
        renders["normalrender"] = {
          "world": "world",
          "title": "World",
        }
        texturepath = "/opt/textures.jar"
        outputdir = "/data/overviewer"
      |||,

      manifests: {
        container::
          k.core.v1.container.new(name='overviewer', image=config.image) +
          k.core.v1.container.withCommand(['/bin/bash', '-euo', 'pipefail', '-c', |||
            while true; do
              overviewer.py --config /etc/config.py
              sleep %s
            done
          ||| % config.update_interval]) +
          k.core.v1.container.withVolumeMounts(k.core.v1.volumeMount.new('data', '/data')) +
          k.core.v1.container.securityContext.withRunAsUser(config.uid),

        nginx_container::
          k.core.v1.container.new(name='nginx', image='nginx:alpine') +
          k.core.v1.container.withVolumeMounts(k.core.v1.volumeMount.new('data', '/usr/share/nginx/html') +
                                               k.core.v1.volumeMount.withSubPath('overviewer') +
                                               k.core.v1.volumeMount.withReadOnly(true)) +
          k.core.v1.container.withPorts([k.core.v1.containerPort.new(port) for port in config.ports]),

        deployment:
          k.apps.v1.deployment.new(name='overviewer', containers=[self.container, self.nginx_container]) +
          if config.single_node then
            k.apps.v1.deployment.spec.template.spec.withHostNetwork(true) +
            k.apps.v1.deployment.spec.template.spec.withVolumes([
              k.core.v1.volume.fromHostPath('data', config.data_host_path),
            ]) +
            k.apps.v1.deployment.spec.strategy.withType('Recreate')
          else {},
      },
    },
}
