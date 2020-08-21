ARG ZEEK_VER
ARG DISTRO

FROM ${DISTRO}

ENV WORKSPACE /build

LABEL maintainer="Vlad Grigorescu <vlad@es.net>"

COPY . /build

WORKDIR /build

RUN ./scripts/install_deps.sh
RUN ./scripts/clone_zeek.sh ${ZEEK_VER}

