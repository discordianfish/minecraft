(import 'minecraft/main.jsonnet') +
{
  _config+: {
      image: "fish/minecraft:" + std.extVar("image_tag")
  }
}
