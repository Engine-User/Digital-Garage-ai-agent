#!/usr/bin/env bash
# Tab-completion for the `DIGITAL_GARAGE` umbrella + every `DIGITAL_GARAGE-*` CLI.
#
# Source from your shell rc:
#     source /path/to/digital_garage-ui/scripts/_completion/digital_garage.bash
#
# Or wire it once per machine:
#     sudo install -m 644 digital_garage.bash /etc/bash_completion.d/digital_garage

#
# What it does:
#   - On the first word after `digital_garage`, complete with the list of
#     subcommands (`mail`, `calendar`, ...).
#   - On subsequent words, complete with the subcommand's first-token
#     subcommands (`list`, `show`, ...) which we cache by parsing the
#     tool's own --help output. Updates lazily; refresh by running
#     `_digital_garage_refresh_cache`.
#   - Same completion works for the individual `digital_garage-foo` scripts.

_digital_garage_scripts_dir() {
    # Resolve the scripts/ dir from the script that sources us. We assume
    # the user sourced the file directly out of scripts/_completion/.
    local self="${BASH_SOURCE[0]}"
    while [ -L "$self" ]; do self=$(readlink "$self"); done
    cd "$(dirname "$self")/.." && pwd
}

declare -A _DIGITAL_GARAGE_SUBS_CACHE=()

_digital_garage_refresh_cache() {
    local dir="$(_digital_garage_scripts_dir)"
    _DIGITAL_GARAGE_SUBS_CACHE=()
    # Prefer the project venv's Python so deps (bcrypt, sqlalchemy, ...)
    # resolve. Falls back to system `python3` for container installs.
    local py="$dir/../venv/bin/python"
    [ -x "$py" ] || py="$(command -v python3)"
    local f
    for f in "$dir"/digital_garage-*; do
        [ -x "$f" ] || continue
        case "$f" in *.bak|*.pyc|*.pre-*) continue ;; esac
        local name="$(basename "$f")"
        local sub="${name#digital_garage-}"
        local help_out
        help_out=$("$py" "$f" --help 2>/dev/null) || continue
        local commands
        commands=$(echo "$help_out" | grep -oE '\{[a-z0-9_,-]+\}' | head -1 \
            | tr -d '{}' | tr ',' ' ')
        _DIGITAL_GARAGE_SUBS_CACHE[$sub]="$commands"
    done
}

_digital_garage_complete() {
    [ ${#_DIGITAL_GARAGE_SUBS_CACHE[@]} -eq 0 ] && _digital_garage_refresh_cache

    local cur="${COMP_WORDS[COMP_CWORD]}"
    local cmd="${COMP_WORDS[0]}"

    # `digital_garage <tab>` → list every subcommand
    if [ "$cmd" = "digital_garage" ]; then
        if [ "$COMP_CWORD" -eq 1 ]; then
            local subs="${!_DIGITAL_GARAGE_SUBS_CACHE[@]} help"
            COMPREPLY=($(compgen -W "$subs" -- "$cur"))
            return 0
        fi
        # `digital_garage foo <tab>` — complete with foo's own subcommands
        local sub="${COMP_WORDS[1]}"
        # `digital_garage help <tab>` lists every subcommand
        if [ "$sub" = "help" ] && [ "$COMP_CWORD" -eq 2 ]; then
            COMPREPLY=($(compgen -W "${!_DIGITAL_GARAGE_SUBS_CACHE[*]}" -- "$cur"))
            return 0
        fi
        if [ "$COMP_CWORD" -eq 2 ]; then
            COMPREPLY=($(compgen -W "${_DIGITAL_GARAGE_SUBS_CACHE[$sub]}" -- "$cur"))
            return 0
        fi
        return 0
    fi

    # Direct `DIGITAL_GARAGE-foo <tab>` (no umbrella)
    local sub="${cmd#digital_garage-}"
    if [ "$COMP_CWORD" -eq 1 ]; then
        COMPREPLY=($(compgen -W "${_DIGITAL_GARAGE_SUBS_CACHE[$sub]}" -- "$cur"))
        return 0
    fi
}

# Register the completion for every digital_garage-* script + the umbrella.
complete -F _digital_garage_complete digital_garage
for f in "$(_digital_garage_scripts_dir)"/digital_garage-*; do
    [ -x "$f" ] || continue
    case "$f" in *.bak|*.pyc|*.pre-*) continue ;; esac
    complete -F _digital_garage_complete "$(basename "$f")"
done
