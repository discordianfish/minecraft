local d = import '../dockerfile.jsonnet';

{
  _config:: {
    dl_url: 'https://papermc.io/api/v2/projects/paper/versions/1.18.1/builds/134/downloads/paper-1.18.1-134.jar',
  },
  Dockerfile: std.join('\n', [
    d.from('ubuntu:20.04'),
    d.workdir('/paper'),
    d.env('PAPER_DL_URL', $._config.dl_url),
    d.run([
      'set -x',
      'apt-get -qy update',
      'apt-get -qy install apt-transport-https curl openjdk-17-jre-headless',
      'curl -Lfo paper.jar "$PAPER_DL_URL"',
      'java -jar /paper/paper.jar -Dpaperclip.patchonly=true',
      'useradd -d /tmp/ minecraft',
      'ln -s /tmp/ logs',
      'mkdir plugins',
      'install -d -o minecraft -g minecraft /data',
    ] + $._config.image_build_run),
    d.volume(['/data']),
  ]),
}
