local k = import "github.com/jsonnet-libs/k8s-alpha/1.19/main.libsonnet";
local minecraft = (import 'kubernetes.jsonnet');


{
  _config+:: {
    image: "foo/bar",
  },

  Dockerfile: ((import 'minecraft/dockerfile.jsonnet') + {_config+:: $._config }).Dockerfile,

  _manifests:: (import 'kubernetes.jsonnet') + {_config+:: $._config },
  "deployment.yaml": std.manifestYamlDoc($._manifests.deployment),
  "pod.yaml": std.manifestYamlDoc(k.core.v1.pod.new("minecraft") + $._manifests.deployment.spec.template),
}
