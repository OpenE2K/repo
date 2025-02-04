# Compile QEMU with E2K support

```sh
# fetch qemu-e2k from main repository
$ git clone --depth=1 -b e2k https://git.mentality.rip/OpenE2K/qemu-e2k.git
# or from mirror on github
$ git clone --depth=1 -b e2k https://github.com/OpenE2K/qemu-e2k.git
$ mkdir -p qemu-e2k/build
$ cd qemu-e2k/build
$ ../configure --target-list=e2k-linux-user --static --disable-capstone --disable-werror
$ nice ninja
$ sudo cp qemu-e2k /usr/local/bin
```

# Setup binfmt

The kernel must support miscellaneous binary formats. You can check this in the kernel's config file.

```sh
$ zgrep CONFIG_BINFMT_MISC /proc/config.gz
CONFIG_BINFMT_MISC=y
# or
CONFIG_BINFMT_MISC=m
```

## systemd

```sh
$ sudo cp binfmt.d/qemu-e2k.conf /etc/binfmt.d/qemu-e2k.conf
$ sudo systemctl restart systemd-binfmt.service
```

## Manual

```sh
$ [ -d /proc/sys/fs/binfmt_misc ] || sudo modprobe binfmt_misc
$ [ -f /proc/sys/fs/binfmt_misc/register ] || sudo mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc
$ echo ':qemu-e2k:M::\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\xaf\x00:\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff:/usr/local/bin/qemu-e2k:OC' | sudo tee /proc/sys/fs/binfmt_misc/register
```

# Setup chroot

## First stage

Prepare a chroot directory.

```sh
# Set path to chroot directory
$ TARGET=/elbrus
# fetch and extract packages from remote repository
$ sudo debootstrap --foreign --arch=e2k-8c elbrus-linux $TARGET https://setwd.ws/osl/8.2
# or from local mirror
$ sudo debootstrap --foreign --arch=e2k-8c elbrus-linux $TARGET file:///repo/elbrus-linux
```

## Second stage

Copy the qemu-e2k static binary to the chroot directory.

```sh
$ cp /usr/local/bin/qemu-e2k $TARGET/usr/local/bin/qemu-e2k
```

Enter into the chroot and finish the instalation process.

```sh
# this will take a while because emulating e2k is not a simple task...
$ PATH="/sbin:/usr/sbin:/bin:/usr/bin" chroot $TARGET /debootstrap/debootstrap --second-stage
```
