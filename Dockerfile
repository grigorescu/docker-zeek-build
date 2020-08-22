ARG DISTRO

FROM ${DISTRO}

ENV WORKSPACE /build

LABEL maintainer="Vlad Grigorescu <vlad@es.net>"

COPY . /build

WORKDIR /build

# We need git, so we can determine if we need C++17 or not
RUN ./scripts/install_deps.sh git

ARG ZEEK_VER
RUN ./scripts/clone_zeek.sh ${ZEEK_VER}

RUN ./scripts/install_deps.sh

RUN ./scripts/build_zeek.sh
