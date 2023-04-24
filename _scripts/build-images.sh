#! /usr/bin/env bash

# catch most errors
set -eE
trap 'echo "[ERROR] Error occurred at $BASH_SOURCE:$LINENO command: $BASH_COMMAND"' ERR

# This script is used to build and tag both docker images while still
# keeping the images in the same Dockerfile.
# Doing this ensures that both images will have synced dependencies.

BASE_TAG="webdev"
VALIDATE_TAG="$BASE_TAG-validator"

docker build --target base -t "$BASE_TAG" .
docker build -t "$VALIDATE_TAG" .
