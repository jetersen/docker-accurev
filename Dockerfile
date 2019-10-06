FROM ubuntu:bionic

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y curl unzip && \
    rm -rf /var/lib/apt/lists/*

ENV ACCUREV_HOME /var/accurev
ENV ACCUREV_VERSION=7.3
ENV POSTGRES_PASSWORD=PASSWORD
ENV PATH $PATH:${ACCUREV_HOME}/bin

ARG user=accurev
ARG group=accurev
ARG uid=1000
ARG gid=1000

RUN groupadd -g ${gid} ${group} \
    && useradd -d "$ACCUREV_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user}

RUN chmod -R 760 ${ACCUREV_HOME}

RUN curl -O -fsSL http://cdn.microfocus.com/cached/legacymf/Products/accurev/accurev${ACCUREV_VERSION}/accurev-${ACCUREV_VERSION}-linux-x86-x64.bin && \
  mv /accurev-${ACCUREV_VERSION}-linux-x86-x64.bin ${ACCUREV_HOME}/accurev.bin

RUN chown -R ${user}:${group} "$ACCUREV_HOME"

USER ${user}
WORKDIR ${ACCUREV_HOME}

RUN mkdir -p ${ACCUREV_HOME}/license && \
  touch ${ACCUREV_HOME}/license/aclicense.txt && \
  chmod +x ./accurev.bin && \
  printf "\nY\n${ACCUREV_HOME}\nY\n\n\n\n${ACCUREV_HOME}/database\n\n\n${POSTGRES_PASSWORD}\n${POSTGRES_PASSWORD}\n\n${ACCUREV_HOME}/license/aclicense.txt\n\n\n2\n\n\n\n\n\n" | ./accurev.bin && \
  rm -rf ./accurev.bin ${ACCUREV_HOME}/license/aclicense.txt ./installer-debug-*.txt AccuRev_Install*.log ./.InstallAnywhere/ ./doc/ ./examples/ ./AccuRev\ Manuals/

COPY ./startup.sh startup.sh

HEALTHCHECK --interval=1m --timeout=10s --start-period=30s --retries=5 CMD accurev info

VOLUME ${ACCUREV_HOME}/storage
VOLUME ${ACCUREV_HOME}/database
# Expose AccuRev on 5050
EXPOSE 5050
# Expose Mosquitto on 1883
EXPOSE 1883

CMD ["./startup.sh"]
