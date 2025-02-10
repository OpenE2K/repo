FROM ubuntu:24.04 AS builder

LABEL org.opencontainers.image.authors="Veniamin Gvozdikov <g.veniamin@googlemail.com>"

WORKDIR /app

RUN apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y \
    build-essential \
    debootstrap \
    git \
    libglib2.0 \
    meson \
    ninja-build \
    pkg-config \
    python3-venv

COPY . .

ARG COMMIT=6c39fd65be
ARG ELBRUS=8.2

RUN git clone --depth=1 -b e2k https://git.mentality.rip/OpenE2K/qemu-e2k.git \
  && git clone --depth=1 https://git.mentality.rip/OpenE2K/repo.git \
  && cd qemu-e2k && git checkout ${COMMIT} && mkdir build && cd build \
  && ../configure \
    --target-list=e2k-linux-user \
    --static \
    --disable-capstone \
    --disable-werror \
  && ninja qemu-e2k \
  && cp qemu-e2k /usr/local/bin/qemu-e2k-static \
  && ln -s qemu-e2k-static /usr/local/bin/qemu-e2k

RUN cd /app/repo && ln -svf "$PWD/debootstrap/scripts"/* \
  /usr/share/debootstrap/scripts

RUN debootstrap --foreign --variant=qemu --arch=e2k-8c elbrus-linux-${ELBRUS} /elbrus
RUN PATH="/sbin:/usr/sbin:/bin:/usr/bin" \
  chroot /elbrus /debootstrap/debootstrap --second-stage

FROM scratch

COPY --from=builder /elbrus /
