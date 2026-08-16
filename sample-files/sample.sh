#!/usr/bin/env bash
#
# Shell sample: variables, expansions, conditionals, loops, heredocs.

set -euo pipefail
IFS=$'\n\t'

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly THEME_FILE="${SCRIPT_DIR}/../themes/Themes of Shibbir-color-theme.json"
readonly DEFAULT_HEX='#EEFFFF'
VERBOSE="${VERBOSE:-0}"

log() {
    local level="$1"
    shift
    printf '[%s] %s\n' "${level}" "$*" >&2
}

usage() {
    cat <<'USAGE'
Usage: sample.sh [-v] [-o OUTPUT] COMMAND

Commands:
  colors    List every hex value used by the theme
  package   Build a .vsix in the repository root
USAGE
}

while getopts ':vo:h' opt; do
    case "${opt}" in
        v) VERBOSE=1 ;;
        o) OUTPUT="${OPTARG}" ;;
        h) usage; exit 0 ;;
        \?) log ERROR "Unknown option: -${OPTARG}"; usage; exit 1 ;;
        :) log ERROR "Option -${OPTARG} requires an argument"; exit 1 ;;
    esac
done
shift $((OPTIND - 1))

command="${1:-colors}"

if [[ ! -f "${THEME_FILE}" ]]; then
    log ERROR "Theme file not found at ${THEME_FILE}"
    exit 1
fi

case "${command}" in
    colors)
        mapfile -t hexes < <(grep -oE '#[0-9A-Fa-f]{6,8}' "${THEME_FILE}" | sort -u)

        for hex in "${hexes[@]}"; do
            if [[ "${hex}" == "${DEFAULT_HEX}" ]]; then
                printf '%s (default)\n' "${hex}"
            else
                printf '%s\n' "${hex}"
            fi
        done

        log INFO "Found ${#hexes[@]} unique colors"
        ;;

    package)
        npx @vscode/vsce package --out "${OUTPUT:-theme.vsix}"
        ;;

    *)
        log ERROR "Unknown command: ${command}"
        usage
        exit 1
        ;;
esac

exit 0
