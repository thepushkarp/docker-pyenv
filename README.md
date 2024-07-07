# Docker image with prebuilt pyenv python versions

<div align="center">
  <img alt="Docker Pulls" src="https://img.shields.io/docker/pulls/thepushkarp/pyenv">
</div>

## Tags
Tags are available in a few formats:

- `<version>-<variant>`: images based on the specified variant with multiple python versions installed, and `<version>` is one of them.
- `<version>`: images based on latest stable Debian release, Bullseye currently, with multiple python versions installed, and `<version>` is one of them.
- `<variant>`: images based on the specified base with unspecified multiple python versions installed.
- `latest-<variant>`: images based on the specified variant with at least latest stable python version, 3.12 currently, installed.
- `latest`: images based on the latest stable Debian release, Bullseye currently, with at least latest stable python version, 3.12 currently, installed.

Versions can be `3`, `3.12`, `3.12.1`, etc, and current supported variants are:

- `alpine`: based on `alpine`, [Dockerfile](https://github.com/thepushkarp/docker-pyenv/blob/main/alpine/Dockerfile)
- `bullseye`: based on `buildpack-deps:bullseye`, [Dockerfile](https://github.com/thepushkarp/docker-pyenv/blob/main/bullseye/Dockerfile)
- `slim-bullseye`: based on `debian:bullseye-slim`, [Dockerfile](https://github.com/thepushkarp/docker-pyenv/blob/main/bullseye/slim/Dockerfile)
- `bookworm`: based on `buildpack-deps:bookworm`, [Dockerfile](https://github.com/thepushkarp/docker-pyenv/blob/main/bookworm/Dockerfile)
- `slim-bookworm`: based on `debian:bookworm-slim`, [Dockerfile](https://github.com/thepushkarp/docker-pyenv/blob/main/bookworm/slim/Dockerfile)
- `focal`: based on `buildpack-deps:focal`, [Dockerfile](https://github.com/thepushkarp/docker-pyenv/blob/main/focal/Dockerfile)
- `slim-focal`: based on `ubuntu:focal`, [Dockerfile](https://github.com/thepushkarp/docker-pyenv/blob/main/focal/slim/Dockerfile)
- `jammy`: based on `buildpack-deps:jammy`, [Dockerfile](https://github.com/thepushkarp/docker-pyenv/blob/main/jammy/Dockerfile)
- `slim-jammy`: based on `ubuntu:jammy`, [Dockerfile](https://github.com/thepushkarp/docker-pyenv/blob/main/jammy/slim/Dockerfile)

## Source

Thanks to [https://hub.docker.com/r/vicamo/pyenv/](https://hub.docker.com/r/vicamo/pyenv/) for the initial code from which this repo was forked.
