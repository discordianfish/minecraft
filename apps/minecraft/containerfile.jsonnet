local c = (import '../../lib/lib.libsonnet').containerfile;

local default_config = {
};

{
  new(opts):
    local config = default_config + opts;
    [
      c.from('ubuntu:20.04'),
      c.workdir('/paper'),
      c.env('PAPER_DL_URL', config.papermc_url),
      c.run([
        'set -x',
        'echo \'APT::Sandbox::User "root";\' > /etc/apt/apt.conf.d/disable-sandbox',
        'apt-get -qy update',
        'apt-get -qy install apt-transport-https curl openjdk-17-jre-headless',
        'curl -Lfo paper.jar "$PAPER_DL_URL"',
        'java -jar /paper/paper.jar -Dpaperclip.patchonly=true',
        'useradd -d /tmp/ minecraft',
        'ln -s /tmp/ logs',
        'mkdir plugins',
        'install -d -o minecraft -g minecraft /data',
      ] + std.flattenArrays([plugin.build_steps for plugin in config.plugins])),
      c.volume(['/data']),
      '',
    ],
}
