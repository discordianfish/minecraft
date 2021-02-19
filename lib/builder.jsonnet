{
  docker_build(path, image)::
  |||
    #!/bin/bash
    set -euo pipefail
    docker build -t %(image)s -f %(path)s .
  |||  % {path: path, image: image},
  docker_push(image):
  |||
    #!/bin/bash
    set -euo pipefail
    docker push %(image)s
  ||| %{image: image}
}
