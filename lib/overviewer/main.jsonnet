local k = import "github.com/jsonnet-libs/k8s-alpha/1.19/main.libsonnet";
local overviewer = (import 'kubernetes.jsonnet');
local builder = (import 'builder.jsonnet');


{
  _config+:: {
    overviewer+: {
      data_host_path: "/data/minecraft",
    },
  },
  //Create Dockerfile
  "overviewer/Dockerfile": (import 'overviewer/dockerfile.jsonnet').Dockerfile,
  "overviewer/config.py": |||
    import os
    worlds["world"] = "/data/world"
    renders["normalrender"] = {
      "world": "world",
      "title": "World",
    }
    texturepath = "/opt/textures.jar"
    outputdir = "/data/overviewer"
  |||,

  // Build, tag and push it
  "overviewer/image-build.sh": builder.docker_build('overviewer/Dockerfile', $._config.overviewer.image),
  "overviewer/image-push.sh": builder.docker_push($._config.overviewer.image),

  // Generate Kubernetes manifests
  _manifests:: (import 'kubernetes.jsonnet') + {_config+:: $._config},
  "overviewer/deployment.yaml": std.manifestYamlDoc($._manifests.deployment),
  "overviewer/pod.yaml": std.manifestYamlDoc(k.core.v1.pod.new("overviewer") + $._manifests.deployment.spec.template),
}
