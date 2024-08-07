#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "update.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:latest AS base

ENV PYENV_ROOT="/opt/pyenv"
ENV PYENV_SHELL="bash"
ENV PATH="${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:$PATH"

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG C.UTF-8

# runtime dependencies
RUN set -eux; \
    apk update; \
    apk add --no-cache \
        bash \
        bzip2 \
        ca-certificates \
        curl \
        git \
        expat \
        libffi \
        mpdecimal \
        ncurses-libs \
        openssl \
        readline \
        sqlite-libs \
        tk \
        xz \
        zlib \
    ;

RUN set -eux; \
    curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash; \
    git clone https://github.com/momo-lab/xxenv-latest \
        ${PYENV_ROOT}/plugins/xxenv-latest \
    ; \
    pyenv update

# > =============================================================== <

FROM base AS builder

# runtime dependencies
RUN set -eux; \
    apk update; \
    apk add --no-cache \
        build-base \
        bzip2-dev \
        libffi-dev \
        ncurses-dev \
        openssl-dev \
        readline-dev \
        sqlite-dev \
        tk-dev \
        xz-dev \
        zlib-dev \
    ;

# > =============================================================== <

FROM builder AS build-all

ARG PYENV_VERSIONS="3.8.19 3.9.19 3.10.14 3.11.9 3.12.4"
ARG ALLOW_FAILURES=

RUN set -eux; \
    for version in ${PYENV_VERSIONS}; do \
        env PYTHON_CONFIGURE_OPTS=" \
            --enable-shared \
            --enable-loadable-sqlite-extensions \
            --with-lto \
            --with-system-expat \
            --with-system-ffi \
            --with-system-mpdec \
            " \
            pyenv install ${version} || test -n "${ALLOW_FAILURES}"; \
    done; \
    pyenv global $(pyenv versions --bare | tac); \
    pyenv versions; \
    \
    find ${PYENV_ROOT}/versions -depth \
        \( \
            \( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
            -o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' -o -name '*.a' \) \) \
            -o \( -type f -a -name 'wininst-*.exe' \) \
        \) -exec rm -rf '{}' +

# > =============================================================== <

FROM base

COPY --from=build-all ${PYENV_ROOT}/versions/ ${PYENV_ROOT}/versions/

RUN set -eux; \
    pyenv rehash; \
    pyenv global $(pyenv versions --bare | tac); \
    pyenv versions; \
    pip install --no-cache-dir --upgrade pip setuptools wheel; \
