ARG ZEEK_VER
ARG DISTRO

FROM ${DISTRO}
LABEL maintainer="Vlad Grigorescu <vlad@es.net>"

COPY . /build

RUN /build/scripts/install_deps.sh
RUN /build/scripts/clone_zeek.sh ${ZEEK_VER}

