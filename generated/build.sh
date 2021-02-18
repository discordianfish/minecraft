#!/bin/bash
set -euo pipefail
docker build -t fish/minecraft:d15475a -f Dockerfile .
docker push fish/minecraft:d15475a

