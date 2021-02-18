#!/bin/bash
set -euo pipefail
docker build -t docker.io/fish/minecraft:eb01ea59d63ee34190ff2358df66b15b5036bdf5 -f Dockerfile .
docker push docker.io/fish/minecraft:eb01ea59d63ee34190ff2358df66b15b5036bdf5

