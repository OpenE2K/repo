# syntax=docker/dockerfile:1

FROM ubuntu:latest AS build
RUN apt-get update && \
	apt-get install -y git build-essential meson python3-venv libglib2.0-dev
RUN git clone --depth=1 -b e2k https://git.mentality.rip/OpenE2K/qemu-e2k.git /qemu-e2k
WORKDIR /qemu-e2k/build
RUN ../configure --target-list=e2k-linux-user --static --disable-capstone --disable-werror && \
    ninja qemu-e2k && \
	mv qemu-e2k /qemu-e2k-static && \
	ninja clean

FROM alpine
COPY --from=build /qemu-e2k-static /usr/local/bin/qemu-e2k-static
RUN ln -s qemu-e2k-static /usr/local/bin/qemu-e2k
