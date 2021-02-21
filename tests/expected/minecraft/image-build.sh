#!/bin/bash
set -euo pipefail
docker build -t docker.io/fish/minecraft:test -f minecraft/Dockerfile .
