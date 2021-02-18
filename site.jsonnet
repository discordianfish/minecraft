local k = import "github.com/jsonnet-libs/k8s-alpha/1.19/main.libsonnet";

local minecraft = (import 'minecraft/kubernetes.jsonnet') + {
  _config+:: {
    image: 'fish/minecraft:1',
  }
};


(import 'minecraft/dockerfile.jsonnet') + {
  "deployment.yaml": std.manifestYamlDoc(minecraft.deployment),
  "pod.yaml": std.manifestYamlDoc(k.core.v1.pod.new("minecraft") + minecraft.deployment.spec.template),
}
