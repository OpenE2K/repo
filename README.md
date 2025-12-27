# Compile QEMU with E2K support

### OpenE2K's qemu-e2k:

```sh
git clone --depth=1 -b e2k https://github.com/OpenE2K/qemu-e2k.git
mkdir -p qemu-e2k/build
cd qemu-e2k/build
../configure --target-list=e2k-linux-user --static --disable-capstone --disable-werror --disable-docs
nice ninja qemu-e2k
sudo cp qemu-e2k /usr/local/bin/qemu-e2k-static
sudo ln -s qemu-e2k-static /usr/local/bin/qemu-e2k
cd ..
```

### MCST's qemu-e2k:

```sh
git clone --depth=1 -b mcst https://git.openelbrus.ru/mcst/qemu
mkdir -p qemu-e2k/build
cd qemu-e2k/build
../configure --target-list=e2k-linux-user --static --disable-capstone --disable-werror --disable-docs
nice ninja qemu-e2k
sudo cp qemu-e2k /usr/local/bin/qemu-e2k-static
sudo ln -s qemu-e2k-static /usr/local/bin/qemu-e2k
cd ..
```

# Clone this repository

```sh
git clone --depth=1 https://github.com/OpenE2K/repo.git
cd repo
```

# Setup binfmt

The kernel must support miscellaneous binary formats. You can check this in the kernel's config file.

```sh
zgrep CONFIG_BINFMT_MISC /proc/config.gz
```

An output must be:

```
CONFIG_BINFMT_MISC=y
# or
CONFIG_BINFMT_MISC=m
```

## systemd

### OpenE2K's qemu-e2k

```sh
sudo cp binfmt.d/qemu-e2k-*.conf /etc/binfmt.d/
sudo systemctl restart systemd-binfmt.service
```

### MCST's qemu-e2k

As MCST's qemu-e2k only supports e2k-64 without check for very old binaries, you can install only `qemu-e2k-64.conf`

```sh
sudo cp binfmt.d/qemu-e2k-64.conf /etc/binfmt.d/
sudo systemctl restart systemd-binfmt.service
```

## Manual

```sh
[ -d /proc/sys/fs/binfmt_misc ] || sudo modprobe binfmt_misc
[ -f /proc/sys/fs/binfmt_misc/register ] || sudo mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc
echo ':qemu-e2k:M::\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\xaf\x00:\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff:/usr/local/bin/qemu-e2k:OCF' | sudo tee /proc/sys/fs/binfmt_misc/register
```

# Install debootstrap scripts

```sh
sudo ln -svf "$PWD/debootstrap/scripts"/* /usr/share/debootstrap/scripts
```

# Setup chroot

## First stage

Prepare a chroot directory.

```sh
# Set path to chroot directory
export TARGET=/elbrus
# Fetch and extract packages from remote repository
sudo debootstrap --foreign --arch=e2k-8c elbrus-linux-8.2 "$TARGET"
```

## Second stage

Finish the instalation process.

```sh
# It will take a while because elbrus emulation is not an easy task.
PATH="/sbin:/usr/sbin:/bin:/usr/bin" sudo chroot "$TARGET" /debootstrap/debootstrap --second-stage
```

# Enter chroot

```sh
# TODO: mount partitions
sudo chroot "$TARGET" /bin/bash
```
