#compdef digital_garage digital_garage-backup digital_garage-calendar digital_garage-contacts digital_garage-cookbook etc tec)
# Zsh tab-completion for the digital_garage umbrella + sub-CLIs.
#
# Drop in any directory on $fpath, e.g.:
#     fpath=(/path/to/digital_garage-ui/scripts/_completion $fpath)
#     autoload -U compinit; compinit
#
# Then `digital_garage <tab>` completes subcommands; `digital_garage mail <tab>`
# completes mail subcommands; `digital_garage-mail <tab>` works the same.

_digital_garage_scripts_dir() {
    local self="${(%):-%x}"
    while [[ -L "$self" ]]; do self="$(readlink "$self")"; done
    cd "${self:h}/.." && pwd
}

typeset -gA _digital_garage_subs

_digital_garage_refresh() {
    _digital_garage_subs=()
    local dir="$(_digital_garage_scripts_dir)"
    local py="$dir/../venv/bin/python"
    [[ -x "$py" ]] || py="$(command -v python3)"
    local f sub help_out commands
    for f in "$dir"/digital_garage-*; do
        [[ -x "$f" ]] || continue
        case "$f" in
            *.bak|*.pyc|*.pre-*) continue ;;
        esac
        sub="${${f:t}#digital_garage-}"
        help_out=$("$py" "$f" --help 2>/dev/null) || continue
        commands=$(echo "$help_out" | grep -oE '\{[a-z0-9_,-]+\}' | head -1 \
            | tr -d '{}' | tr ',' ' ')
        _digital_garage_subs[$sub]="$commands"
    done
}

_digital_garage() {
    [[ ${#_digital_garage_subs} -eq 0 ]] && _digital_garage_refresh

    local cmd="${words[1]}"

    if [[ "$cmd" == "digital_garage" ]]; then
        if (( CURRENT == 2 )); then
            local -a subs=(${(k)_digital_garage_subs} help)
            _describe 'subcommand' subs
            return
        fi
        local sub="${words[2]}"
        if [[ "$sub" == "help" ]] && (( CURRENT == 3 )); then
            local -a subs=(${(k)_digital_garage_subs})
            _describe 'subcommand' subs
            return
        fi
        if (( CURRENT == 3 )); then
            local -a sc=(${(s/ /)_digital_garage_subs[$sub]})
            _describe 'command' sc
            return
        fi
        return
    fi

    # digital_garage-foo <tab>
    local sub="${cmd#digital_garage-}"
    if (( CURRENT == 2 )); then
        local -a sc=(${(s/ /)_digital_garage_subs[$sub]})
        _describe 'command' sc
        return
    fi
}

_digital_garage "$@"
