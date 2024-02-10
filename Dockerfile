FROM ubuntu:20.04 as builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get upgrade -y zip wget automake build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev \
    zlib1g-dev make g++ tmux git jq curl libncursesw5 libtool autoconf llvm libnuma-dev

WORKDIR /cardano-node

## Download latest cardano-cli, cardano-node tx-submit-service version static build
RUN wget -O cardano-8_7_2-aarch64-static-musl-ghc_963.zip https://github.com/armada-alliance/cardano-node-binaries/blob/main/static-binaries/cardano-8_7_2-aarch64-static-musl-ghc_963.zip?raw=true \
    && unzip cardano-8_7_2-aarch64-static-musl-ghc_963.zip

## Install libsodium (needed for ScheduledBlocks.py)
WORKDIR /build/libsodium
RUN git clone https://github.com/input-output-hk/libsodium
RUN cd libsodium && \
    git checkout 66f017f1 && \
    ./autogen.sh && ./configure && make && make install

FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get upgrade -y curl wget zip netbase jq libnuma-dev lsof bc python3-pip git && \
    rm -rf /var/lib/apt/lists/*

## Copy Libsodium refs from builder image
COPY --from=builder /usr/local/lib /usr/local/lib

## Create node folders
WORKDIR /configuration
WORKDIR /configuration/cardano
WORKDIR /configuration/defaults
# WORKDIR /configuration/defaults/byron-mainnet
WORKDIR /configuration/byron
WORKDIR /home/cardano/.local/bin
WORKDIR /home/cardano/pi-pool/files
WORKDIR /home/cardano/pi-pool/scripts
WORKDIR /home/cardano/pi-pool/logs
WORKDIR /home/cardano/pi-pool/.keys
WORKDIR /home/cardano/git
WORKDIR /home/cardano/tmp

COPY --from=builder /cardano-node/cardano-8_7_2-aarch64-static-musl-ghc_963/* /home/cardano/.local/bin/

WORKDIR /configuration
# COPY /configuration/cardano/shelley_qa-alonzo-genesis.json /configuration/cardano
# COPY /configuration/cardano/alonzo-babbage-test-genesis.json /configuration/cardano
# COPY /configuration/defaults/byron-mainnet/configuration.yaml /configuration/defaults/byron-mainnet
COPY /configuration/babbage/alonzo-babbage-test-genesis.json /configuration/babbage/
COPY /configuration/babbage/conway-babbage-test-genesis.json /configuration/babbage/
COPY /configuration/byron/configuration.yaml /configuration/byron

WORKDIR /home/cardano/pi-pool/scripts
COPY ./scripts/automate.sh /home/cardano/pi-pool/scripts
COPY ./scripts/kill-processes-and-remove-private-testnet.sh /home/cardano/pi-pool/scripts
COPY ./scripts/db-sync-start.sh /home/cardano/pi-pool/scripts
COPY ./scripts/mkfiles.sh /home/cardano/pi-pool/scripts
COPY ./scripts/mkfiles-topology.sh /home/cardano/pi-pool/scripts
COPY ./scripts/mkfiles-cardano.sh /home/cardano/pi-pool/scripts
COPY ./scripts/mkfiles-start.sh /home/cardano/pi-pool/scripts
COPY ./scripts/update-1.sh /home/cardano/pi-pool/scripts

RUN git clone https://github.com/asnakep/poolLeaderLogs.git
RUN pip install -r /home/cardano/pi-pool/scripts/poolLeaderLogs/pip_requirements.txt

## Download gLiveView from original source
RUN wget https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/env \
    && wget https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/gLiveView.sh
RUN chmod +x env
RUN chmod +x gLiveView.sh

ENV PATH="/home/cardano/.local/bin:$PATH"

HEALTHCHECK --interval=10s --timeout=60s --start-period=300s --retries=3 CMD curl -f http://localhost:12798/metrics || exit 1

STOPSIGNAL SIGINT

## Set up the entrypoint
COPY /scripts/automate.sh / 
COPY /scripts/mkfiles.sh / 
COPY /scripts/mkfiles-topology.sh /
COPY /scripts/mkfiles-cardano.sh /
COPY /scripts/mkfiles-start.sh /
COPY /scripts/db-sync-start.sh / 
COPY /scripts/update-1.sh / 

RUN chmod +x /automate.sh
CMD ["./automate.sh"]
#ENTRYPOINT ["bash", "-c"]
