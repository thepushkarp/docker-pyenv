#!/usr/bin/env bash
set -Eeuo pipefail

allow_failures=
while test $# -gt 0; do
    case "$1" in
    --allow-failures) allow_failures=yes; shift ;;
    *)
        echo "Unknown argument: $1" >&2; exit 1 ;;
    esac
done

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

# Get the machine hardware name
architecture=$(uname -m)

# Map the architecture to Docker platform codes
case "$architecture" in
    x86_64)
        docker_platform="linux/amd64"
        ;;
    i386 | i486 | i586 | i686)
        docker_platform="linux/386"
        ;;
    armv6l)
        docker_platform="linux/arm/v6"
        ;;
    armv7l)
        docker_platform="linux/arm/v7"
        ;;
    aarch64 | arm64 | armv8l)
        docker_platform="linux/arm64"
        ;;
    ppc64)
        docker_platform="linux/ppc64"
        ;;
    ppc64le)
        docker_platform="linux/ppc64le"
        ;;
    s390x)
        docker_platform="linux/s390x"
        ;;
    *)
        echo "Unsupported architecture: $architecture"
        exit 1
        ;;
esac

versions=(
    $(docker run --platform $docker_platform thepushkarp/pyenv sh -c " \
        pyenv update >/dev/null 2>&1; \
        for prefix in \$(pyenv install --list | \
            grep -e '^  [[:digit:]]\(\.[[:digit:]]\+\)\+$' | \
            cut -d. -f1,2 | \
            sort -u -V) \
        ; do \
            pyenv latest --known \$prefix; \
        done | sort -u -V"
    )
)

versions=(
    $(docker run thepushkarp/pyenv sh -c " \
        pyenv update >/dev/null 2>&1; \
        for prefix in \$(pyenv install --list | \
            grep -e '^  [[:digit:]]\(\.[[:digit:]]\+\)\+$' | \
            cut -d. -f1,2 | \
            sort -u -V) \
        ; do \
            pyenv latest --known \$prefix; \
        done | sort -u -V"
    )
)

declare -A blacklisted

for dir in \
    alpine {buster,bullseye,bookworm,focal,jammy}{/slim,} \
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
    if [ -n "${allow_failures}" ]; then
        available+=( "${versions[@]}" )
    else
        for version in "${versions[@]}"; do
            if [ -z "${blacklisted["$suite-$version"]:-}" ]; then
                available+=("$version")
            fi
        done
    fi

    sed -ri \
        -e "s!%%BASE_IMAGE%%!${base}!" \
        -e "s!%%PYENV_VERSIONS%%!${available[*]}!" \
        ${allow_failures:+-e "s!^ARG ALLOW_FAILURES=.*!ARG ALLOW_FAILURES=true!"} \
        "$dir/Dockerfile"
done
