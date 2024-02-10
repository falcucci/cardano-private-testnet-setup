#!/usr/bin/env bash

set -x

##Configuration for relay and block producing node
CNIMAGENAME="cardano-node-private-coway"                           ## Name of the Cardano docker image
CNVERSION="latest"                                                ## Version of the cardano-node. It must match with the version of the docker image
#CNNETWORK="preprod"                                              ## Use "mainnet" if connecting node to the mainnet
CNMODE="relay"                                                   ## Use "bp" if you configure the node as block production node
CNPORT="3001"                                                    ## Define the port of the node
CNPROMETHEUS_PORT="12799"                                        ## Define the port for the Prometheus metrics
CN_CONFIG_PATH="/configuration"          ## Path to the folder where the Cardano config files are stored on the host system


##Do not edit/change section below!
##---------------------------------
# docker run \
docker run --detach \
    --name=cardano-node-${CNNETWORK}-${CNVERSION} \
    --restart=always \
    -p ${CNPORT}:${CNPORT} \
    -p ${CNPROMETHEUS_PORT}:12798 \
    -p 8090:8090 \
    -e NETWORK=${CNNETWORK} \
    -e NODE_MODE=${CNMODE} \
    -e PORT=${CNPORT} \
    -e CARDANO_RTS_OPTS="${CN_RTS_OPTS}" \
    -e BFID=${CN_BF_ID} \
    -e POOLID=${CN_POOL_ID} \
    -e POOLTICKER=${CN_POOL_TICKER} \
    -e SB_VRF_SKEY_PATH=${CN_VRF_SKEY_PATH} \
    -e CARDANO_NODE_SOCKET_PATH=/tmp/db/node.socket \
    -v ${CN_CONFIG_PATH}:/home/cardano/pi-pool/files  \
    ${CNIMAGENAME}:${CNVERSION}
