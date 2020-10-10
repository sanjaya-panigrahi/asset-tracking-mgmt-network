#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This is a collection of bash functions used by different scripts

ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/reliance-network.com/orderers/orderer.reliance-network.com/msp/tlscacerts/tlsca.reliance-network.com-cert.pem
PEER0_INFRASTRUCTURE_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/infrastructure.reliance-network.com/peers/peer0.infrastructure.reliance-network.com/tls/ca.crt
PEER0_POWER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/power.reliance-network.com/peers/peer0.power.reliance-network.com/tls/ca.crt
PEER0_ENTERTAINMENT_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/entertainment.reliance-network.com/peers/peer0.entertainment.reliance-network.com/tls/ca.crt
PEER0_CAPITAL_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/capital.reliance-network.com/peers/peer0.capital.reliance-network.com/tls/ca.crt
PEER0_COMMUNICATION_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/communication.reliance-network.com/peers/peer0.communication.reliance-network.com/tls/ca.crt


# verify the result of the end-to-end test
verifyResult() {
  if [ "$1" -ne 0 ]; then
    echo "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
    echo "========= ERROR !!! FAILED to execute Reliance Network Bootstrap ==========="
    echo
    exit 1
  fi
}

# Set OrdererOrg.Admin globals
setOrdererGlobals() {
  CORE_PEER_LOCALMSPID="OrdererMSP"
  CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/reliance-network.com/orderers/orderer.reliance-network.com/msp/tlscacerts/tlsca.reliance-network.com-cert.pem
  CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/reliance-network.com/users/Admin@reliance-network.com/msp
}

setGlobals() {
  PEER=$1
  ORG=$2
  if [ "$ORG" == 'infrastructure' ]; then
    CORE_PEER_LOCALMSPID="InfrastructureMSP"
    CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_INFRASTRUCTURE_CA
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/infrastructure.reliance-network.com/users/Admin@infrastructure.reliance-network.com/msp
    if [ "$PEER" -eq 0 ]; then
      CORE_PEER_ADDRESS=peer0.infrastructure.reliance-network.com:7051
    else
      CORE_PEER_ADDRESS=peer1.infrastructure.reliance-network.com:8051
    fi
  elif [ "$ORG" == 'power' ]; then
    CORE_PEER_LOCALMSPID="PowerMSP"
    CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_POWER_CA
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/power.reliance-network.com/users/Admin@power.reliance-network.com/msp
    if [ "$PEER" -eq 0 ]; then
      CORE_PEER_ADDRESS=peer0.power.reliance-network.com:9051
    else
      CORE_PEER_ADDRESS=peer1.power.reliance-network.com:10051
    fi
  elif [ "$ORG" == 'entertainment' ]; then
    CORE_PEER_LOCALMSPID="EntertainmentMSP"
    CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ENTERTAINMENT_CA
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/entertainment.reliance-network.com/users/Admin@entertainment.reliance-network.com/msp
    if [ "$PEER" -eq 0 ]; then
      CORE_PEER_ADDRESS=peer0.entertainment.reliance-network.com:15051
    else
      CORE_PEER_ADDRESS=peer1.entertainment.reliance-network.com:16051
    fi
  elif [ "$ORG" == 'communication' ]; then
    CORE_PEER_LOCALMSPID="CommunicationMSP"
    CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_COMMUNICATION_CA
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/communication.reliance-network.com/users/Admin@communication.reliance-network.com/msp
    if [ "$PEER" -eq 0 ]; then
      CORE_PEER_ADDRESS=peer0.infrastructure.reliance-network.com:11051
    else
      CORE_PEER_ADDRESS=peer1.infrastructure.reliance-network.com:12051
    fi
  elif [ "$ORG" == 'capital' ]; then
    CORE_PEER_LOCALMSPID="CapitalMSP"
    CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_CAPITAL_CA
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/capital.reliance-network.com/users/Admin@capital.reliance-network.com/msp
    if [ "$PEER" -eq 0 ]; then
      CORE_PEER_ADDRESS=peer0.communication.reliance-network.com:13051
    else
      CORE_PEER_ADDRESS=peer1.communication.reliance-network.com:14051
    fi
  else
    echo "================== ERROR !!! ORG Unknown =================="
  fi
}

updateAnchorPeers() {
  PEER=$1
  ORG=$2
  setGlobals "$PEER" "$ORG"

  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    set -x
    peer channel update -o orderer.reliance-network.com:7050 -c "$CHANNEL_NAME" -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx >&log.txt
    res=$?
    set +x
  else
    set -x
    peer channel update -o orderer.reliance-network.com:7050 -c "$CHANNEL_NAME" -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls "$CORE_PEER_TLS_ENABLED" --cafile $ORDERER_CA >&log.txt
    res=$?
    set +x
  fi
  cat log.txt
  verifyResult $res "Anchor peer update failed"
  echo "===================== Anchor peers updated for org '$CORE_PEER_LOCALMSPID' on channel '$CHANNEL_NAME' ===================== "
  sleep "$DELAY"
  echo
}

## Sometimes Join takes time hence RETRY at least 5 times
joinChannelWithRetry() {
  PEER=$1
  ORG=$2
  setGlobals "$PEER" "$ORG"

  set -x
  peer channel join -b "$CHANNEL_NAME".block >&log.txt
  res=$?
  set +x
  cat log.txt
  if [ $res -ne 0 -a "$COUNTER" -lt "$MAX_RETRY" ]; then
    COUNTER=$(expr "$COUNTER" + 1)
    echo "peer${PEER}.${ORG} failed to join the channel, Retry after $DELAY seconds"
    sleep "$DELAY"
    joinChannelWithRetry "$PEER" "$ORG"
  else
    COUNTER=1
  fi
  verifyResult $res "After $MAX_RETRY attempts, peer${PEER}.${ORG} has failed to join channel '$CHANNEL_NAME' "
}