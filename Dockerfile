FROM openjdk:8-jdk

RUN apt-get update && apt-get install -y git curl

ENV ACCUREV_INSTALL /var/accurev
ENV ACCUREV_HOME /var/accurev/home

ARG user=accurev
ARG group=accurev
ARG uid=1000
ARG gid=1000

RUN mkdir -p ${ACCUREV_INSTALL}

RUN groupadd -g ${gid} ${group} \
    && useradd -d "$ACCUREV_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user}

RUN chmod -R 777 ${ACCUREV_HOME}

VOLUME ${ACCUREV_HOME}

ENV ACCUREV_VERSION=7.0.0

ARG ACCUREV_URL=http://rocky.josephp.tech:8082/artifactory/accurev-local/accurev-${ACCUREV_VERSION}-linux-x86-x64-clientonly.bin

COPY accurev_linux.out /usr/share/accurev/accurev_linux.out

RUN curl -fsSL ${ACCUREV_URL} -o /usr/share/accurev/accurev.bin \
  && chmod +x /usr/share/accurev/accurev.bin

RUN chown -R ${user}:${group} "$ACCUREV_INSTALL"

RUN /usr/share/accurev/accurev.bin -i silent -f /usr/share/accurev/accurev_linux.out

RUN chmod +x ${ACCUREV_INSTALL}/bin/accurev

ENV PATH $PATH:${ACCUREV_INSTALL}/bin

USER ${user}

RUN accurev
