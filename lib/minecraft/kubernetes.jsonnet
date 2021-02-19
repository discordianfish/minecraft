local k = import "github.com/jsonnet-libs/k8s-alpha/1.19/main.libsonnet";

{
  _config+:: {
    image: "fish/minecraft",
    port: 25565,
    memory_limit: "1024M",
    single_node: true, // FIXME: make this something more meaningful "static host assignment" etc
                       // or a mixin..
    data_host_path: "/data/minecraft",
  },
  deployment:
    k.apps.v1.deployment.new(name="minecraft", containers=[
      k.core.v1.container.new(name="minecraft", image=$._config.image) +
      k.core.v1.container.withWorkingDir("/data") +
      k.core.v1.container.withCommand(['/bin/bash', '-euc', |||
        rm -f cache
        # Ugly hacks to separate code (server/plugin jars) from runtime state
        ln -s /paper/cache .
        mkdir -p plugins
        cp -nrs /paper/plugins/* plugins/ # Symlink all files in /paper/plugins/* to plugins/
        echo eula=true > eula.txt
        exec java -Xmx%s -Xms%s -jar /paper/paper.jar -W /data
      ||| % [ $._config.memory_limit, $._config.memory_limit ]]) +
      k.core.v1.container.withPorts(k.core.v1.containerPort.new($._config.port)) +
      if $._config.single_node then
        k.core.v1.container.withVolumeMounts(k.core.v1.volumeMount.new('data', '/data'))
      else {}
    ]) +
    if $._config.single_node then
      k.apps.v1.deployment.spec.template.spec.withHostNetwork(true) +
      k.apps.v1.deployment.spec.template.spec.withVolumes([
        k.core.v1.volume.fromHostPath('data', $._config.data_host_path)
      ]) +
      k.apps.v1.deployment.spec.strategy.withType("Recreate")
    else {}
}
