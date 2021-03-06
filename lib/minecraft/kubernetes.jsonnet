local k = import "github.com/jsonnet-libs/k8s-alpha/1.19/main.libsonnet";

{
  _config+:: {
    image: error "Must define image",
    uid: 1000,
    port: 25565,
    memory_limit: "2048M",
    data_host_path: "/data/minecraft",
    container: {}, // container mixin
  },
  _container::
    k.core.v1.container.new(name="minecraft", image=$._config.image) +
    k.core.v1.container.withWorkingDir("/data") +
    k.core.v1.container.withCommand(['/bin/bash', '-euc', |||
      rm -f cache
      # Ugly hacks to separate code (server/plugin jars) from runtime state
      ln -s /paper/cache .
      mkdir -p plugins
      cp -nrs /paper/plugins/* plugins/ # Symlink all files in /paper/plugins/* to plugins/
      echo eula=true > eula.txt
      exec java -Xmx%s -Xms%s -jar /paper/paper.jar -W /data \
        | sed -u 's#/\(register\|login\).*#/\1 [REDACTED]#'
    ||| % [ $._config.memory_limit, $._config.memory_limit ]]) +
    k.core.v1.container.withPorts(k.core.v1.containerPort.new($._config.port)) +
    k.core.v1.container.withStdin(true) +
    k.core.v1.container.withTty(true) +
    k.core.v1.container.securityContext.withRunAsUser($._config.uid) +
    $._config.container +
    if $._config.single_node then
      k.core.v1.container.withVolumeMounts(k.core.v1.volumeMount.new('data', '/data'))
    else {},
  deployment:
    k.apps.v1.deployment.new(name="minecraft", containers=[$._container]) +
    if $._config.single_node then
      k.apps.v1.deployment.spec.template.spec.withHostNetwork(true) +
      k.apps.v1.deployment.spec.template.spec.withVolumes([
        k.core.v1.volume.fromHostPath('data', $._config.data_host_path)
      ]) +
      k.apps.v1.deployment.spec.strategy.withType("Recreate")
    else {}
}
