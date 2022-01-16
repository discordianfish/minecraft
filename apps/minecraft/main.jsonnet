local k = import 'github.com/jsonnet-libs/k8s-alpha/1.19/main.libsonnet';
local lib = import 'lib.libsonnet';

local default_config = {
  single_node: false,
  memory_limit_mb: 2 * 1024,
  image: error 'Must define image',
  papermc_url: error 'Must specify papermc_url',
  uid: 1000,
  port: 25565,
  build_job: false,
  data_host_path: '/data/minecraft',
  args: [
    '-XX:+UseG1GC',
    '-XX:+ParallelRefProcEnabled',
    '-XX:MaxGCPauseMillis=200',
    '-XX:+UnlockExperimentalVMOptions',
    '-XX:+DisableExplicitGC',
    '-XX:+AlwaysPreTouch',
    '-XX:G1NewSizePercent=30',
    '-XX:G1MaxNewSizePercent=40',
    '-XX:G1HeapRegionSize=8M',
    '-XX:G1ReservePercent=20',
    '-XX:G1HeapWastePercent=5',
    '-XX:G1MixedGCCountTarget=4',
    '-XX:InitiatingHeapOccupancyPercent=15',
    '-XX:G1MixedGCLiveThresholdPercent=90',
    '-XX:G1RSetUpdatingPauseTimePercent=5',
    '-XX:SurvivorRatio=32',
    '-XX:+PerfDisableSharedMem',
    '-XX:MaxTenuringThreshold=1',
    '-Dusing.aikars.flags=https://mcflags.emc.gs',
    '-Daikars.new.flags=true',
  ],
  plugins: [],
};

{
  new(opts):
    local config = default_config + opts;
    {
      Containerfile: (import 'containerfile.jsonnet').new(config),
      manifests: {
        container::
          k.core.v1.container.new(name='minecraft', image=config.image) +
          k.core.v1.container.withWorkingDir('/data') +
          k.core.v1.container.withCommand(['/bin/bash', '-euc', |||
            mkdir -p plugins
            cp -nrs /paper/plugins/* plugins/ # Symlink all files in /paper/plugins/* to plugins/
            echo eula=true > eula.txt
            exec java -Xmx%sM -Xms%sM %s -DbundlerRepoDir=/paper -jar /paper/paper.jar -W /data \
              | sed -u 's#/\(register\|login\).*#/\1 [REDACTED]#'
          ||| % [config.memory_limit_mb, config.memory_limit_mb, std.join(' ', config.args)]]) +
          k.core.v1.container.withPorts(k.core.v1.containerPort.new(config.port)) +
          k.core.v1.container.withStdin(true) +
          k.core.v1.container.withTty(true) +
          k.core.v1.container.securityContext.withRunAsUser(config.uid) +
          if config.single_node then
            k.core.v1.container.withVolumeMounts(k.core.v1.volumeMount.new('data', '/data'))
          else {},

        deployment:
          k.apps.v1.deployment.new(name='minecraft', containers=[self.container]) +
          if config.single_node then
            k.apps.v1.deployment.spec.template.spec.withHostNetwork(true) +
            k.apps.v1.deployment.spec.template.spec.withVolumes([
              k.core.v1.volume.fromHostPath('data', config.data_host_path),
            ]) +
            k.apps.v1.deployment.spec.strategy.withType('Recreate')
          else {},
      } + if config.build_job then lib.podman_build_job(config.image, self.Containerfile) else {},
    },
}
