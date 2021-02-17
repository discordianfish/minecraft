FROM ubuntu:20.04
WORKDIR /paper
ENV PAPER_DL_URL=https://papermc.io/api/v2/projects/paper/versions/1.16.5/builds/468/downloads/paper-1.16.5-468.jar
RUN apt-get -qy update && \
    apt-get -qy install apt-transport-https curl openjdk-8-jre-headless && \
    curl -Lsfo paper.jar "$PAPER_DL_URL" && \
    java -jar paper.jar --help && \
    useradd -d /tmp/ minecraft && \
    ln -s /tmp/ logs && \
    install -d -o minecraft -g minecraft /data
USER minecraft
VOLUME ['/data']