#!/usr/bin/env bash
#
# Renders node peers to stdout.
# Globals:
#   NCTL - path to nctl home directory.
# Arguments:
#   Network ordinal identifier.
#   Node ordinal identifier.

# Import utils.
source $NCTL/sh/utils/misc.sh

#######################################
# Displays to stdout current node peers.
# Globals:
#   NCTL - path to nctl home directory.
# Arguments:
#   Network ordinal identifer.
#   Node ordinal identifer.
#######################################
function _view_peers() {
    node_address=$(get_node_address $1 $2)
    log "network #$1 :: node #$2 :: $node_address :: peers:"
    curl -s --header 'Content-Type: application/json' \
        --request POST $(get_node_address_rpc $1 $2) \
        --data-raw '{
            "id": 1,
            "jsonrpc": "2.0",
            "method": "info_get_peers"
        }' | jq '.result.peers'
}

#######################################
# Destructure input args.
#######################################

# Unset to avoid parameter collisions.
unset net
unset node

for ARGUMENT in "$@"
do
    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)
    case "$KEY" in
        net) net=${VALUE} ;;
        node) node=${VALUE} ;;
        *)
    esac
done

# Set defaults.
net=${net:-1}
node=${node:-"all"}

#######################################
# Main
#######################################

if [ $node = "all" ]; then
    source $NCTL/assets/net-$net/vars
    for node_idx in $(seq 1 $NCTL_NET_NODE_COUNT)
    do
        _view_peers $net $node_idx
        echo "------------------------------------------------------------------------------------------------------------------------------------"
        echo "------------------------------------------------------------------------------------------------------------------------------------"
    done
else
    _view_peers $net $node
fi
