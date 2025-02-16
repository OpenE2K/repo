#!/bin/sh

set -e

binfmt="/proc/sys/fs/binfmt_misc"
conf="/etc/binfmt.d/qemu-e2k.conf"

[ -f "$binfmt/register" ] || mount binfmt_misc -t binfmt_misc "$binfmt"

function extract_name() {
    echo "$1" | cut -f2 -d:
}

function extract_exe() {
    echo "$1" | cut -f7 -d:
}

function binfmt_register() {
    line=$1
    name=$(extract_name "$line")
    exe=$(extract_exe "$line")
    [ ! -x "$exe" ] && echo "skip $name" && return
    echo "register $name"
    echo "$line" > "$binfmt/register"
}

function binfmt_unregister() {
    line="$1"
    name=$(extract_name "$line")
    if [[ -f "$binfmt/$name" ]]; then
        echo "unregister $name"
        echo -1 > "$binfmt/$name"
    fi
}

function binfmt_unregister_all() {
    for line in $(cat "$conf"); do
        binfmt_unregister "$line"
    done
}

function binfmt_register_all() {
    for line in $(cat "$conf"); do
        binfmt_unregister "$line"
        binfmt_register "$line"
    done
}

command=$1
case "$command" in
    ""|"register")
        binfmt_register_all
        ;;
    "unregister")
        binfmt_unregister_all
        ;;
    *)
        echo "unexpected command $command"
        exit 1
        ;;
esac
