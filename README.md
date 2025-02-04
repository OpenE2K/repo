# Compile QEMU with E2K support

```sh
git clone --depth=1 -b e2k https://git.mentality.rip/OpenE2K/qemu-e2k.git
mkdir -p qemu-e2k/build
cd qemu-e2k/build
../configure --target-list=e2k-linux-user --static --disable-capstone --disable-werror
nice ninja qemu-e2k
sudo cp qemu-e2k /usr/local/bin
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
git clone --depth=1 https://git.mentality.rip/OpenE2K/repo.git
cd repo
sudo ln -svf $PWD/debootstrap/scripts/* /usr/share/debootstrap/scripts
```

# Setup chroot

## First stage

Prepare a chroot directory.

```sh
# Set path to chroot directory
export TARGET=/elbrus
sudo mkdir -p $TARGET
# Fetch and extract packages from remote repository
sudo debootstrap --foreign --arch=e2k-8c elbrus-linux-8.2 $TARGET
```

## Second stage

Copy the qemu-e2k static binary to the chroot directory.

```sh
sudo mkdir -p $TARGET/usr/local/bin
sudo cp /usr/local/bin/qemu-e2k $TARGET/usr/local/bin/qemu-e2k
```

Enter into the chroot and finish the instalation process.

```sh
PATH="/sbin:/usr/sbin:/bin:/usr/bin" sudo chroot $TARGET /debootstrap/debootstrap --second-stage
```
