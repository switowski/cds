#!/bin/sh

# quit on errors:
set -o errexit

# quit on unbound symbols:
set -o nounset

# FFMpeg
mkdir -p /tmp/ffmpeg
# FIXME could we remove the --no-check-certificate?
wget -O - https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-64bit-static.tar.xz --no-check-certificate | tar --strip-components 1 -xJ -C /tmp/ffmpeg && export PATH=$PATH:/tmp/ffmpeg

# Pip
pip install --upgrade pip setuptools py
pip install twine wheel coveralls requirements-builder
