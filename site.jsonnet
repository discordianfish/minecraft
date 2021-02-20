(import 'minecraft/main.jsonnet') +
(import 'minecraft/plugins/amk_mc_auth_se.jsonnet') +
(import 'minecraft/plugins/grief_prevention.jsonnet') +
{
  _config+: {
      image: "docker.io/fish/minecraft:" + std.extVar("image_tag")
  }
}
