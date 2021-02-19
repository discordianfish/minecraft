local k = import "github.com/jsonnet-libs/k8s-alpha/1.19/main.libsonnet";
local minecraft = (import 'kubernetes.jsonnet');
local builder = (import 'builder.jsonnet');


{
  _config+:: {
    image: "fish/minecraft",
  },
  //Create Dockerfile
  Dockerfile: ((import 'minecraft/dockerfile.jsonnet') + {_config+:: $._config}).Dockerfile,

  // Build, tag and push it
  "image-build.sh": builder.docker_build('Dockerfile', $._config.image),
  "image-push.sh": builder.docker_push($._config.image),

  // Generate Kubernetes manifests
  _manifests:: (import 'kubernetes.jsonnet') + {_config+:: $._config},
  "deployment.yaml": std.manifestYamlDoc($._manifests.deployment),
  "pod.yaml": std.manifestYamlDoc(k.core.v1.pod.new("minecraft") + $._manifests.deployment.spec.template),
}
