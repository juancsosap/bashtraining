#!/bin/bash

./clean.bash
_TIME=$(date +%Y-%m-%d_%H:%M:%S_%A)
echo "INI : $_TIME" >> errors.log

_l_nodes=$(cat nodes.lst | tr ";" " " | awk '{print $1}' | tr "\n" " ")


_n_nodes=$(cat nodes.lst | wc -l)
for (( _i_nodes=1; _i_nodes<=_n_nodes; _i_nodes++ )); do
    _ip_node=$(echo $_l_nodes | tr " " "\n" | head -$_i_nodes | tail -1)
    if (( $(./ping.bash $_ip_node)>0 )); then
	  ./basicdata.bash $_ip_node 2>> errors.log &
    fi
done
