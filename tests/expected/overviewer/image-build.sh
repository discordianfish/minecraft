#!/bin/bash
set -euo pipefail
docker build -t docker.io/fish/overviewer:test -f overviewer/Dockerfile .
