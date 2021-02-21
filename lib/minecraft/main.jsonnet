local k = import "github.com/jsonnet-libs/k8s-alpha/1.19/main.libsonnet";
local builder = (import 'builder.jsonnet');


{
  local manifests = (import 'kubernetes.jsonnet') + {_config+:: $._config},
  //Create Dockerfile
  "minecraft/Dockerfile": ((import 'minecraft/dockerfile.jsonnet') + {_config+:: $._config}).Dockerfile,

  // Build, tag and push it
  "minecraft/image-build.sh": builder.docker_build('minecraft/Dockerfile', $._config.image),
  "minecraft/image-push.sh": builder.docker_push($._config.image),

  // Generate Kubernetes manifests
  "minecraft/deployment.yaml": std.manifestYamlDoc(manifests.deployment),
  "minecraft/pod.yaml": std.manifestYamlDoc(k.core.v1.pod.new("minecraft") + manifests.deployment.spec.template),
}
