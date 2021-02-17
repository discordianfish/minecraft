local k = import "github.com/jsonnet-libs/k8s-alpha/1.19/main.libsonnet";

local minecraft = (import 'lib/minecraft.jsonnet') + {
  _config+:: {
    image: 'fish/minecraft:0',
  }
};

std.manifestYamlDoc(k.core.v1.list.new(std.objectValues(minecraft)))
