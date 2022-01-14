local c = (import 'lib.libsonnet').containerfile;

local default_config = {
};

{
  new(opts):
    local config = default_config + opts;
    [
      c.from('debian:stretch'),
      c.run([
        'apt-get -qy update',
        'apt-get -qy install apt-transport-https curl gpg',
        'echo deb https://overviewer.org/debian ./ >> /etc/apt/sources.list.d/overviewer.list',
        'curl -Lsf https://overviewer.org/debian/overviewer.gpg.asc | apt-key add -',
        'apt-get -qy update',
        'apt-get -qy install minecraft-overviewer',
        'curl -Lsfo /opt/textures.jar https://overviewer.org/textures/%s' % config.texture_version,
      ]),
      c.copy('overviewer/config.py', '/etc/config.py'),
      '',
    ],
}
