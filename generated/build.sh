#!/bin/bash
set -euo pipefail
docker build -t fish/minecraft:b8643260b28be20c3ec9a43f48d7a8c029d89cf9 -f Dockerfile .
docker push fish/minecraft:b8643260b28be20c3ec9a43f48d7a8c029d89cf9

