#!/usr/bin/env bash
set -e

# Command line args
agents="$1"
interval="$2"
limit="$3"

# Env vars
INDRA_ETH_RPC_URL="${INDRA_ETH_RPC_URL}"
INDRA_NODE_URL="${INDRA_NODE_URL}"
INDRA_NATS_URL="${INDRA_NATS_URL}"
BOT_REGISTRY_URL="${BOT_REGISTRY_URL}"
FUNDER_MNEMONIC="${FUNDER_MNEMONIC}"
TOKEN_ADDRESS="${TOKEN_ADDRESS}"

# Wait for services to come up
function wait_for {
  name=$1
  target=$2
  tmp=${target#*://} # remove protocol
  host=${tmp%%/*} # remove path if present
  if [[ ! "$host" =~ .*:[0-9]{1,5} ]] # no port provided
  then
    echo "$host has no port, trying to add one.."
    if [[ "${target%://*}" == "http" ]]
    then host="$host:80"
    elif [[ "${target%://*}" == "https" ]]
    then host="$host:443"
    else echo "Error: missing port for host $host derived from target $target" && exit 1
    fi
  fi
  echo "Waiting for $name at $target ($host) to wake up..."
  wait-for -t 60 $host 2> /dev/null
}

wait_for "nats" "$INDRA_NATS_URL"
wait_for "ethprovider" "$INDRA_ETH_RPC_URL"
wait_for "registry" "$BOT_REGISTRY_URL"
wait_for "node" "$INDRA_NODE_URL"

# Create private keys
echo "Creating new private keys"
agent_key="0x`hexdump -n 32 -e '"%08X"' < /dev/urandom | tr '[:upper:]' '[:lower:]'`"

agent_address="`node <<<'var eth = require("ethers"); console.log((new eth.Wallet("'"$agent_key"'")).address);'`"
agent_pub_key="`node <<<'var eth = require("ethers"); console.log((new eth.Wallet("'"$agent_key"'")).publicKey);'`"

# Fund agent w/0.001 eth
echo "Funding agent: $agent_address (pubKey: ${agent_pub_key}) with eth"
node contracts/dist/src.ts/cli.js fund --to-address="$agent_address" --amount="0.001" --eth-provider="$INDRA_ETH_RPC_URL" --from-mnemonic="$FUNDER_MNEMONIC"
echo

# Fund agent w/tokens
echo "Funding agent: $agent_address (pubKey: ${agent_pub_key}) with tokens"
node contracts/dist/src.ts/cli.js drip --eth-provider="$INDRA_ETH_RPC_URL" --private-key="$agent_key" --address-book="contracts/dist/address-book.json" 

echo "Starting agent container.."

function finish {
  echo && echo "Bot container exiting.." && exit
}
trap finish SIGTERM SIGINT
echo "Launching agent!";echo
node dist/src/index.js bot \
  --private-key "$agent_key" \
  --concurrency-index "$agent" \
  --interval "$interval" \
  --limit "$limit" \
  --token-address "$TOKEN_ADDRESS"
