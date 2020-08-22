ARG DISTRO

FROM ${DISTRO}

ENV WORKSPACE /build

LABEL maintainer="Vlad Grigorescu <vlad@es.net>"

COPY . /build

WORKDIR /build

RUN ./scripts/install_deps.sh

ARG ZEEK_VER
RUN ./scripts/clone_zeek.sh ${ZEEK_VER}

RUN ./scripts/build_zeek.sh
