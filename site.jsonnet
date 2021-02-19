(import 'minecraft/main.jsonnet') +
(import 'minecraft/plugins/amk_mc_auth_se.jsonnet') +
{
  _config+: {
      image: "docker.io/fish/minecraft:" + std.extVar("image_tag")
  }
}
