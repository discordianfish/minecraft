local k = import "github.com/jsonnet-libs/k8s-alpha/1.19/main.libsonnet";

{
  _config+:: {
    image_build_run+:: [
      "curl -Lsfo plugins/Dynmap.jar 'https://github.com/webbukkit/dynmap/releases/download/v3.1-beta-7/Dynmap-3.1-beta7-spigot.jar'",
    ],
    container+: k.core.v1.container.withPortsMixin(k.core.v1.containerPort.new(8123)),
  }
}
