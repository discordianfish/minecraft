(import 'minecraft/main.jsonnet') +
{
  _config+: {
      image: "docker.io/fish/minecraft:" + std.extVar("image_tag")
  }
}
