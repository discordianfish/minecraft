{
  docker_build(path, image)::
    |||
      #!/bin/bash
      set -euo pipefail
      docker build -t %(image)s -f %(path)s .
    ||| % { path: path, image: image },
  docker_push(image):
    |||
      #!/bin/bash
      set -euo pipefail
      docker push %(image)s
    ||| % { image: image },
  from(image, as=''):
    if as != '' then
      'FROM %s AS %s' % [image, as]
    else
      'FROM %s' % image,
  workdir(workdir): 'WORKDIR %s' % workdir,
  env(key, value): 'ENV %s=%s' % [key, value],
  run(script): 'RUN ' + std.join(' && \\\n    ', script),
  user(user): 'USER %s' % user,
  volume(volumes): 'VOLUME [%s]' % std.join(',', std.map(std.escapeStringJson, volumes)),
  entrypoint(entrypoint): 'ENTRYPOINT [%s]' % std.join(',', entrypoint),
  copy(src, dst): 'COPY "%s" "%s"' % [src, dst],
}
