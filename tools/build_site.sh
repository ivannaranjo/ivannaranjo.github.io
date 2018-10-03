#! /usr/bin/env bash
# Runs the site within a docker image.

docker run \
    -it \
    -p 4000:4000 \
    -v ${HOME}/github/ivannaranjo.github.io/:/var/repo/:rw \
    --rm \
    --workdir /var/repo/ \
    jekyll \
    bundle exec jekyll build
