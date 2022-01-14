local k = import "github.com/jsonnet-libs/k8s-alpha/1.19/main.libsonnet";

{
  _config+:: {
    uid: 1000,
    ports: [80, 443],
    update_interval: 3600,
  },
  overview_container:
    k.core.v1.container.new(name="overviewer", image=$._config.overviewer.image) +
    k.core.v1.container.withCommand(["/bin/bash", "-euo", "pipefail", "-c", |||
      while true; do
        overviewer.py --config /etc/config.py
        sleep %s
      done
    ||| % $._config.update_interval]) +
    k.core.v1.container.withVolumeMounts(k.core.v1.volumeMount.new('data', '/data')) +
    k.core.v1.container.securityContext.withRunAsUser($._config.uid),

  nginx_container:
    k.core.v1.container.new(name="nginx", image="nginx:alpine") +
    k.core.v1.container.withVolumeMounts(k.core.v1.volumeMount.new('data', '/usr/share/nginx/html') +
                                         k.core.v1.volumeMount.withSubPath('overviewer') +
                                         k.core.v1.volumeMount.withReadOnly(true)) +
    k.core.v1.container.withPorts([k.core.v1.containerPort.new(port) for port in $._config.ports]),

  deployment:
    k.apps.v1.deployment.new(name="overviewer", containers=[$.overview_container, $.nginx_container]) +
    if $._config.single_node then
      k.apps.v1.deployment.spec.template.spec.withHostNetwork(true) +
      k.apps.v1.deployment.spec.template.spec.withVolumes([
        k.core.v1.volume.fromHostPath('data', $._config.overviewer.data_host_path)
      ]) +
      k.apps.v1.deployment.spec.strategy.withType("Recreate")
    else {}
}
