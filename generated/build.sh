#!/bin/bash
set -euo pipefail
docker build -t fish/minecraft:1b8a38f -f Dockerfile .
docker push fish/minecraft:1b8a38f

