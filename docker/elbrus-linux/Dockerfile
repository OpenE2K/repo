# syntax=docker/dockerfile:1

FROM numas13/qemu-e2k AS qemu-e2k

FROM ubuntu:latest AS build
RUN apt-get update && \
	apt-get install -y debootstrap git
ARG arch=e2k-8c
ARG suite=elbrus-linux-8.2
RUN git clone --depth=1 -b master https://git.mentality.rip/OpenE2K/repo.git /repo && \
    ln -svf /repo/debootstrap/scripts/* /usr/share/debootstrap/scripts && \
	debootstrap --foreign --arch=$arch $suite /osl
COPY --from=qemu-e2k /usr/local/bin/qemu-e2k-static /osl/usr/local/bin/qemu-e2k-static
RUN ln -s qemu-e2k-static /osl/usr/local/bin/qemu-e2k && \
	PATH="/sbin:/usr/sbin:/bin:/usr/bin" chroot /osl /debootstrap/debootstrap --second-stage

FROM scratch
COPY --from=build /osl /
