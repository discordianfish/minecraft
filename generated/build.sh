#!/bin/bash
set -euo pipefail
docker build -t docker.io/fish/minecraft:0b8be74c104f39eb31c2d8a9771bc1f7e185efa6 -f Dockerfile .
docker push docker.io/fish/minecraft:0b8be74c104f39eb31c2d8a9771bc1f7e185efa6

