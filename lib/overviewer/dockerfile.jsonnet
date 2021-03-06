local d = import '../dockerfile.jsonnet';

{
  _config+:: {
    textures_version: "1.16.1",
  },
  Dockerfile: std.join("\n", [
    d.from("debian:stretch"),
    d.run([
      'apt-get -qy update',
      'apt-get -qy install apt-transport-https curl gpg',
      'echo deb https://overviewer.org/debian ./ >> /etc/apt/sources.list.d/overviewer.list',
      'curl -Lsf https://overviewer.org/debian/overviewer.gpg.asc | apt-key add -',
      'apt-get -qy update',
      'apt-get -qy install minecraft-overviewer',
      'curl -Lsfo /opt/textures.jar https://overviewer.org/textures/%s' % $._config.textures_version,
    ]),
   d.copy('overviewer/config.py', '/etc/config.py'),
  ])
}
