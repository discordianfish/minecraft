local k = import "github.com/jsonnet-libs/k8s-alpha/1.19/main.libsonnet";

{
  _config+:: {
    image_build_run+:: [
      "curl -Lsfo plugins/BlueMap.jar 'https://github.com/BlueMap-Minecraft/BlueMap/releases/download/v1.3.1/BlueMap-1.3.1-spigot.jar'",
    ],
    container+: k.core.v1.container.withPortsMixin(k.core.v1.containerPort.new(8100)),
  }
}
