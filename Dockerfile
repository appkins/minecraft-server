FROM debian:stable-slim AS download

RUN apt-get -y update
RUN apt-get -y install curl unzip

WORKDIR /opt

RUN download="$(curl https://www.minecraft.net/en-us/download/server/bedrock/ \
    | grep 'bin-linux' \
    | sed 's:^.*<a href="\(.*\)\.zip".*$:\1:')" && \
    curl $download.zip -o server.zip && \
    unzip server.zip -d /data

FROM debian:stable-slim AS app

RUN apt-get -y update
RUN apt-get -y install net-tools libcurl4 openssl

WORKDIR /data

COPY --from=download /data/ /data/

CMD ["./bedrock_server"]  