# Compile QEMU with E2K support

```sh
git clone --depth=1 -b e2k https://git.mentality.rip/OpenE2K/qemu-e2k.git
mkdir -p qemu-e2k/build
cd qemu-e2k/build
../configure --target-list=e2k-linux-user --static --disable-capstone --disable-werror
nice ninja qemu-e2k
sudo cp qemu-e2k /usr/local/bin/qemu-e2k-static
sudo ln -s qemu-e2k-static /usr/local/bin/qemu-e2k
cd ..
```

# Clone this repository

```sh
git clone --depth=1 https://git.mentality.rip/OpenE2K/repo.git
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

```sh
sudo cp binfmt.d/qemu-e2k.conf /etc/binfmt.d/qemu-e2k.conf
sudo systemctl restart systemd-binfmt.service
```

## Manual

```sh
[ -d /proc/sys/fs/binfmt_misc ] || sudo modprobe binfmt_misc
[ -f /proc/sys/fs/binfmt_misc/register ] || sudo mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc
echo ':qemu-e2k:M::\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\xaf\x00:\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff:/usr/local/bin/qemu-e2k:OC' | sudo tee /proc/sys/fs/binfmt_misc/register
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
sudo debootstrap --foreign --variant=qemu --arch=e2k-8c elbrus-linux-8.2 "$TARGET"
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

# Run on Docker

Before start check binfmt configuration above on your system

```sh
docker build -t elbrus .
```

Build qemu from commit --build-arg COMMIT=<hash>
Extract another version of distro --build-arg ELBRUS=<version>

Run container

```sh
docker run -it --rm elbrus bash
03c968b2de3b / # uname -im
e2k QEMU
```
