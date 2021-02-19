local d = import '../dockerfile.jsonnet';

{
  _config:: {
    dl_url: "https://papermc.io/api/v2/projects/paper/versions/1.16.5/builds/468/downloads/paper-1.16.5-468.jar"
  },
  Dockerfile: std.join("\n", [
    d.from("ubuntu:20.04"),
    d.workdir("/paper"),
    d.env("PAPER_DL_URL", $._config.dl_url),
    d.run([
      'apt-get -qy update',
      'apt-get -qy install apt-transport-https curl openjdk-8-jre-headless',
      'curl -Lsfo paper.jar "$PAPER_DL_URL"',
      'java -jar paper.jar --help',
      'useradd -d /tmp/ minecraft',
      'ln -s /tmp/ logs',
      'mkdir plugins',
      'install -d -o minecraft -g minecraft /data'
    ] + $._config.image_build_run),
    d.user("minecraft"),
    d.volume(["/data"]),
  ])
}
