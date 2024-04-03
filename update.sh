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

eol_majors=($(curl -s https://endoflife.date/api/python.json | jq -r '.[] | select(.eol < $date) | .cycle' --arg date "$(date +%Y-%m-%d)" | sort -u -V))

pyenv_majors=($(docker run -it thepushkarp/pyenv sh -c " \
        pyenv update >/dev/null 2>&1; \
        pyenv install --list | \
        grep -e '^  3\(\.[[:digit:]]\+\)\+$' | \
        cut -d. -f1,2 | \
        sort -u -V"
    )
)

pyenv_majors=($(echo "${pyenv_majors[@]}" | tr -d '\r'))

majors=()
for version in "${pyenv_majors[@]}"; do
    if [[ ! " ${eol_majors[@]} " =~ " ${version} " ]]; then
        majors+=("$version")
    fi
done

versions=(
    $(for version in "${majors[@]}"; do
        pyenv latest --known "$version"
    done | sort -u -V)
)

echo "Found Python versions: ${versions[*]}"

declare -A blacklisted

for dir in \
    alpine {buster,bullseye,bookworm,focal,jammy}{/slim,} \
; do
    variant="$(basename "$dir")"

    echo "Updating $dir..."

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

    allow_failures_conditional_script=""
    if [ -n "${allow_failures}" ]; then
        allow_failures_conditional_script="-e s!^ARG ALLOW_FAILURES=.*!ARG ALLOW_FAILURES=true!"
    fi

    sed -ri "" \
        "s/%%BASE_IMAGE%%/${base}/g; \
        s/%%PYENV_VERSIONS%%/${available[*]}/g \
        ${allow_failures_conditional_script}" \
        "${dir}/Dockerfile"
done
