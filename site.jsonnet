local k = import "github.com/jsonnet-libs/k8s-alpha/1.19/main.libsonnet";
local d = import 'lib/dockerfile.jsonnet';

local minecraft = (import 'lib/minecraft.jsonnet') + {
  _config+:: {
    image: 'fish/minecraft:1',
  }
};

{
  "deployment.yaml": std.manifestYamlDoc(minecraft.deployment),
  "pod.yaml": std.manifestYamlDoc(k.core.v1.pod.new("minecraft") + minecraft.deployment.spec.template),
  Dockerfile: std.join("\n", [
    d.from("ubuntu:20.04"),
    d.workdir("/paper"),
    d.env("PAPER_DL_URL", "https://papermc.io/api/v2/projects/paper/versions/1.16.5/builds/468/downloads/paper-1.16.5-468.jar"),
    d.run([
      'apt-get -qy update',
      'apt-get -qy install apt-transport-https curl openjdk-8-jre-headless',
      'curl -Lsfo paper.jar "$PAPER_DL_URL"',
      'java -jar paper.jar --help',
      'useradd -d /tmp/ minecraft',
      'ln -s /tmp/ logs',
      'install -d -o minecraft -g minecraft /data',
    ]),
    d.user("minecraft"),
    d.volume(["/data"]),
  ])
  // FIXME: Add content hash over dockerfile to use in image and create build script here that tags and pushes image propery
}
