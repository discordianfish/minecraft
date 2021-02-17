local d = import 'lib/dockerfile.jsonnet';

std.join("\n", [
  d.from("ubuntu:20.04"),
  d.workdir("/paper"),
  d.env("PAPER_DL_URL", "https://papermc.io/api/v2/projects/paper/versions/1.16.5/builds/468/downloads/paper-1.16.5-468.jar"),
  d.run([
    'apt-get -qy update',
    'apt-get -qy install apt-transport-https curl openjdk-8-jre-headless',
    'curl -Lsfo paper.jar "$PAPER_DL_URL"',
    'echo "eula=true" > eula.txt',
    'java -jar paper.jar --help',
    'useradd -d /tmp/ minecraft',
    'ln -s /tmp/ logs',
    'install -d -o minecraft -g minecraft /data',
  ]),
  d.user("minecraft"),
  d.volume(["/data"]),
])
