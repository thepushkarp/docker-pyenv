#!/usr/bin/env bash
set -Eeuo pipefail

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

generated_warning() {
    cat <<-EOF
#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "update.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

EOF
}

versions=(
    $(docker run vicamo/pyenv sh -c " \
        for prefix in \$(pyenv install --list | \
            grep -e '^  [[:digit:]]\(\.[[:digit:]]\+\)\+$' | \
            cut -d. -f1,2 | \
            sort -u -V) \
        ; do \
            pyenv latest -p \$prefix; \
        done | sort -u -V"
    )
)

declare -A blacklisted
# https://github.com/vicamo/docker-pyenv/runs/4473301383
blacklisted["buster-2.3.7"]=1
# https://github.com/vicamo/docker-pyenv/runs/4473546041
blacklisted["buster-2.4.6"]=1
# https://github.com/vicamo/docker-pyenv/runs/4473706322
blacklisted["buster-2.5.6"]=1
blacklisted["buster-2.6.9"]=1
blacklisted["buster-3.0.1"]=1
blacklisted["buster-3.2.6"]=1
blacklisted["buster-3.3.7"]=1
blacklisted["buster-3.4.10"]=1
# https://github.com/vicamo/docker-pyenv/runs/4473301216
blacklisted["bullseye-2.5.6"]=1
# https://github.com/vicamo/docker-pyenv/runs/4473545988
blacklisted["bullseye-2.6.9"]=1
# https://github.com/vicamo/docker-pyenv/runs/4473706117
blacklisted["bullseye-3.0.1"]=1
blacklisted["bullseye-3.2.6"]=1
blacklisted["bullseye-3.3.7"]=1
blacklisted["bullseye-3.4.10"]=1

for dir in \
    {buster,bullseye}{/slim,} \
; do
    variant="$(basename "$dir")"

    [ -d "$dir" ] || continue

    case "$variant" in
    slim) suite=$(basename "$(dirname "$dir")") ;;
    *)    suite="$variant" ;;
    esac
    base="$(< "$dir/base")"
    template="$(basename "$(readlink -f "$dir/template")")"

    { generated_warning; cat "$template"; } > "$dir/Dockerfile"

    available=()
    for version in "${versions[@]}"; do
        if [ -z "${blacklisted["$suite-$version"]:-}" ]; then
            available+=("$version")
        fi
    done

    sed -ri \
        -e "s!%%BASE_IMAGE%%!${base}!" \
        -e "s!%%PYENV_VERSIONS%%!${available[*]}!" \
        "$dir/Dockerfile"
done
