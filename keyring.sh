#!/usr/bin/env bash
#
# Yamada Hayao
# Twitter: @Hayao0819
# Email  : hayao@fascone.net
#
# (c) 2019-2020 Fascode Network.
#
# keyring.sh
#
# Script to import AlterLinux and ArchLinux keys.
#


set -e

script_path="$(readlink -f ${0%/*})"


# Set pacman.conf when build alterlinux
alter_pacman_conf="${script_path}/system/pacman.conf"


# Color echo
# usage: echo_color -b <backcolor> -t <textcolor> -d <decoration> [Text]
#
# Text Color
# 30 => Black
# 31 => Red
# 32 => Green
# 33 => Yellow
# 34 => Blue
# 35 => Magenta
# 36 => Cyan
# 37 => White
#
# Background color
# 40 => Black
# 41 => Red
# 42 => Green
# 43 => Yellow
# 44 => Blue
# 45 => Magenta
# 46 => Cyan
# 47 => White
#
# Text decoration
# You can specify multiple decorations with ;.
# 0 => All attributs off (ノーマル)
# 1 => Bold on (太字)
# 4 => Underscore (下線)
# 5 => Blink on (点滅)
# 7 => Reverse video on (色反転)
# 8 => Concealed on

echo_color() {
    local backcolor
    local textcolor
    local decotypes
    local echo_opts
    local OPTIND_bak="${OPTIND}"
    unset OPTIND

    echo_opts="-e"

    while getopts 'b:t:d:n' arg; do
        case "${arg}" in
            b) backcolor="${OPTARG}" ;;
            t) textcolor="${OPTARG}" ;;
            d) decotypes="${OPTARG}" ;;
            n) echo_opts="-n -e"     ;;
        esac
    done

    shift $((OPTIND - 1))

    echo ${echo_opts} "\e[$([[ -v backcolor ]] && echo -n "${backcolor}"; [[ -v textcolor ]] && echo -n ";${textcolor}"; [[ -v decotypes ]] && echo -n ";${decotypes}")m${@}\e[m"
    OPTIND=${OPTIND_bak}
}


# Show an INFO message
# $1: message string
msg_info() {
    local _msg="${1}"
    echo "$( echo_color -t '36' '[keyring.sh]')    $( echo_color -t '32' 'Info') ${_msg}"
}


# Show an Warning message
# $1: message string
msg_warn() {
    local _msg="${1}"
    echo "$( echo_color -t '36' '[keyring.sh]') $( echo_color -t '33' 'Warning') ${_msg}" >&2
}


# Show an debug message
# $1: message string
msg_debug() {
    local _msg="${1}"
    if [[ ${debug} = true ]]; then
        echo "$( echo_color -t '36' '[keyring.sh]')   $( echo_color -t '35' 'Debug') ${_msg}"
    fi
}


# Show an ERROR message then exit with status
# $1: message string
# $2: exit code number (with 0 does not exit)
msg_error() {
    local _msg="${1}"
    echo "$( echo_color -t '36' '[keyring.sh]')   $( echo_color -t '31' 'Error') ${_msg}" >&2
}


# Show usage
_usage () {
    echo "usage ${0} [options]"
    echo
    echo " General options:"
    echo "    -a | --alter-add     Add alterlinux-keyring."
    echo "    -r | --alter-remove  Remove alterlinux-keyring."
    echo "    -c | --arch-add      Add archlinux-keyring."
    echo "    -h | --help          Show this help and exit."
    exit "${1}"
}


# Check if the package is installed.
checkpkg() {
    local _pkg
    _pkg=$(echo "${1}" | cut -d'/' -f2)

    if [[ ${#} -gt 2 ]]; then
        msg_error "Multiple package specification is not available."
    fi

    if [[ -n $( pacman -Q "${_pkg}" 2> /dev/null| awk '{print $1}' ) ]]; then
        echo -n "true"
    else
        echo -n "false"
    fi
}


_pacman_install() {
    for i in ${@}; do
        if [[ $(checkpkg "${i}") = false ]]; then
            pacman -S --noconfirm "${i}"
        fi
    done
}


run() {
    msg_info "Running ${@}"
    ${@}
}


prepare() {
    if [[ ! ${UID} = 0 ]]; then
        msg_error "You dont have root permission."
        msg_error 'Please run as root.'
        exit 1
    fi

    if [[ ! -f "${alter_pacman_conf}" ]]; then
        msg_error "${alter_pacman_conf} does not exist."
        exit 1
    fi
    #pacman -Sy
}


update_arch_key() {
    pacman-key --init
    pacman-key --populate archlinux
    _pacman_install core/archlinux-keyring
    pacman-key --refresh-keys
    pacman -Sy
}


update_alter_key() {
    curl -L -o "/tmp/fascode.pub" "https://山d.com/repo/fascode.pub"
    pacman-key -a "/tmp/fascode.pub"
    rm -f "/tmp/fascode.pub"
    pacman-key --lsign-key development@fascode.net

    pacman --config "${alter_pacman_conf}" -Sy --noconfirm
    pacman --config "${alter_pacman_conf}" -S --noconfirm alter-stable/alterlinux-keyring

    pacman-key --init
    pacman-key --populate alterlinux
    pacman -Sy
}


remove_alter_key() {
    pacman-key -d BDC396346243AB57ACD090F9F50544048389DA36
    if checkpkg alterlinux-keyring; then
        pacman -Rsnc --noconfirm alterlinux-keyring
    fi
    pacman -Sy
}


# 引数解析
while getopts 'arch-:' arg; do
    case "${arg}" in
        # alter-add
        a)
            run prepare
            run update_alter_key
            ;;
        # alter-remove
        r)
            run prepare
            run remove_alter_key
            ;;
        # arch-add
        c)
            run prepare
            run update_arch_key
            ;;
        # help
        h) 
            _usage 0
            ;;
        -)
            case "${OPTARG}" in
                alter-add)
                    run prepare
                    run update_alter_key
                    ;;
                alter-remove)
                    run prepare
                    run remove_alter_key
                    ;;
                arch-add)
                    run prepare
                    run update_arch_key
                    ;;
                help)
                    _usage 0
                    ;;
                *)
                    _usage 1
                    ;;
            esac
            ;;
	*) _usage; exit 1;;
    esac
done


# 引数が何もなければ全てを実行する
if [[ ${#} = 0 ]]; then
    run prepare
    # run update_arch_key
    run update_alter_key
fi
