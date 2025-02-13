# syntax=docker/dockerfile:1

FROM scratch
ARG SUITE=elbrus-linux-8.2
ARG ARCH=e2k-8c
ADD dist/$SUITE-$ARCH.tar.xz /
CMD ["/bin/bash"]
