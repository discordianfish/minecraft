local lib = import 'lib.libsonnet';

local build_version = std.extVar('build_version');
local container_registry = 'docker.io/fish';
local overviewer_app = (import 'apps/overviewer/main.jsonnet');
local minecraft_app = (import 'apps/minecraft/main.jsonnet');

local image(name) = container_registry + '/' + name + ':' + build_version;

local minecraft_version = '1.18.1';

local minecraft = minecraft_app.new({
  image: image('minecraft'),
  papermc_url: 'https://papermc.io/api/v2/projects/paper/versions/' + minecraft_version + '/builds/134/downloads/paper-' + minecraft_version + '-134.jar',
  single_node: true,  // FIXME: make this something more meaningful "static host assignment" etc
  overviewer+: {
    image: 'docker.io/fish/overviewer:' + std.extVar('image_tag'),
  },
  memory_limit: 2 * 1024 + 'M',
  plugins: [
    (import 'apps/minecraft/plugins/amk_mc_auth_se.jsonnet'),
    (import 'apps/minecraft/plugins/grief_prevention.jsonnet'),
    (import 'apps/minecraft/plugins/geyser.jsonnet'),
    (import 'apps/minecraft/plugins/dynmap.jsonnet'),
  ],
  build_job: true,
});

local overviewer = overviewer_app.new({
  image: image('minecraft'),
  texture_version: minecraft_version,
});


lib.render(
  lib.build({
    minecraft: minecraft.manifests,
    overviewer: overviewer.manifests,
  })
) + {
  ['containerfiles/' + image('minecraft')]: std.join('\n', minecraft.Containerfile),
  ['containerfiles/' + image('overviewer')]: std.join('\n', overviewer.Containerfile),
}
