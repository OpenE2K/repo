#!/bin/sh

set -e

script=$(readlink -f "$0")
scriptdir=$(dirname "$script")

CACHE_DIR="$scriptdir/cache"
mkdir -p "$CACHE_DIR"

SUITE=elbrus-linux-8.2
ARCH=e2k-8c

COMMAND="$1"
shift

if [[ -n "$1" ]]; then
    SUITE="$1"
    shift
fi

if [[ -n "$1" ]]; then
    ARCH="$1"
    shift
fi

TARGET="$scriptdir/fs/$SUITE-$ARCH"
DIST="$scriptdir/dist"

echo "Suite: $SUITE"
echo "Arch: $ARCH"
echo "Build dir: $TARGET"
echo "Dist dir: $DIST"
echo

case $COMMAND in
    "debootstrap")
        debootstrap --foreign --cache-dir="$CACHE_DIR" --variant=qemu \
            --arch=$ARCH $SUITE "$TARGET"

        PATH="/sbin:/usr/sbin:/bin:/usr/bin" chroot "$TARGET" /debootstrap/debootstrap \
            --second-stage
        ;;
    "tar")
        if [[ ! -d "$TARGET" ]]; then
            echo "Error: $TARGET is not build"
            exit 1
        fi
        tar cvpJf "$DIST"/$SUITE-$ARCH.tar.xz -C "$TARGET" \
            --exclude "./proc/*" \
            --exclude "./run/*" \
            --exclude "./sys/*" \
            --exclude "./var/cache/*" \
            --exclude "./var/tmp/*" \
            --exclude "./tmp/*" \
            --exclude "./usr/local/bin/qemu-e2k*" \
            .
        ;;
    "clean")
        if [[ -d "$TARGET" ]]; then
            rm -rf "$TARGET"
        fi
        ;;
    *)
        echo "unexpected command $COMMAND"
        exit 1
        ;;
esac
