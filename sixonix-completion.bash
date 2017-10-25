__comp_sixonix_run() {
    local flags="
        --width
        --height
        --fullscreen
    "
    case "${COMP_WORDS[COMP_CWORD]}" in
    -*) COMPREPLY=($(compgen -W "${flags}" -- ${COMP_WORDS[COMP_CWORD]})) ;;
    *) COMPREPLY=($(compgen -W "$($1 list)" -- ${COMP_WORDS[COMP_CWORD]})) ;;
    esac
}

__comp_sixonix() {
    local flags="--help"
    local cmds="
        install
        list
        run
        shuffle-run
    "

    if [ "$COMP_CWORD" -eq "1" ]; then
        case "${COMP_WORDS[1]}" in
        -*) COMPREPLY=($(compgen -W "${flags}" -- ${COMP_WORDS[1]})) ;;
        *) COMPREPLY=($(compgen -W "${cmds}" -- ${COMP_WORDS[1]})) ;;
        esac
    fi

    case "${COMP_WORDS[1]}" in
    run) __comp_sixonix_run $1 ;;
    *) ;;
    esac
}

complete -F __comp_sixonix sixonix sixonix.py
