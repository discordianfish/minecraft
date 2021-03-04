(import 'minecraft/main.jsonnet') +
(import 'minecraft/plugins/amk_mc_auth_se.jsonnet') +
(import 'minecraft/plugins/grief_prevention.jsonnet') +
(import 'minecraft/plugins/geyser.jsonnet') +
(import 'overviewer/main.jsonnet') +
{
  _config+: {
    image: "docker.io/fish/minecraft:" + std.extVar("image_tag"),
    single_node: true, // FIXME: make this something more meaningful "static host assignment" etc
    overviewer+: {
      image: "docker.io/fish/overviewer:" + std.extVar("image_tag"),
    },
    memory_limit: 2 * 1024 + 'M',
  }
}
