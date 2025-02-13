# syntax=docker/dockerfile:1

FROM alpine AS src
RUN apk add --no-cache git meson
ARG QEMU_BRANCH=e2k
ARG QEMU_REPO=https://github.com/OpenE2K/qemu-e2k.git
RUN git clone --depth=1 -b $QEMU_BRANCH $QEMU_REPO /src/qemu-e2k
WORKDIR /src/qemu-e2k
RUN meson subprojects download berkeley-testfloat-3 berkeley-softfloat-3

FROM src AS build
RUN apk add --no-cache musl-dev gcc ninja glib-dev glib-static
WORKDIR /src/qemu-e2k/build
RUN ../configure --target-list=e2k-linux-user --static --disable-capstone \
        --disable-werror --disable-docs --disable-system
RUN ninja qemu-e2k && \
    mv qemu-e2k /qemu-e2k-static && \
    ninja clean

FROM scratch
COPY --from=build /qemu-e2k-static /
