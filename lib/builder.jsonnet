{
  docker(path, image)::
  |||
    #!/bin/bash
    set -euo pipefail
    docker build -t %(image)s -f %(path)s .
    docker push %(image)s
  |||  % {path: path, image: image}
}
