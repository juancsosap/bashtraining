#!/bin/bash

./killer.bash  2>> errors.log

_F_SORT(){
  cat $1 | sort | uniq > file.tmp
  mv file.tmp $1
}
#
_l_nodes=$(cat fail.lst | grep CONN | tr ";" " " | awk '{print $1}' | tr "\n" " ")
echo _l_nodes= $_l_nodes
_n_nodes=$(cat fail.lst | grep CONN | wc -l)
echo _n_nodes= $_n_nodes
for (( _i_nodes=1; _i_nodes<=_n_nodes; _i_nodes++ )); do
  _ip_node=$(echo $_l_nodes | tr " " "\n" | head -$_i_nodes | tail -1)
  rm "temp/basicdata/$_ip_node.tmp" 2> /dev/null
  rm "temp/operdata/$_ip_node.tmp" 2> /dev/null
  if (( $(./ping.bash $_ip_node)>0 )); then
    ./basicdata.bash $_ip_node 2>> errors.log &
  fi
done

_F_SORT "nodes.lst"
_F_SORT "data/nodes.dat"
_F_SORT "data/ospf_neighbors.dat"
_F_SORT "data/temps.dat"
_F_SORT "data/cards.dat"
_F_SORT "data/mdas.dat"
_F_SORT "data/fans.dat"
_F_SORT "data/pems.dat"
_F_SORT "data/syncs.dat"
_F_SORT "data/ptps.dat"
_F_SORT "data/ptp-peers.dat"
_F_SORT "data/ints.dat"
_F_SORT "data/ospf_ints.dat"
_F_SORT "data/bgp_neis.dat"
_F_SORT "data/paths.dat"
_F_SORT "data/lsps.dat"
_F_SORT "data/sdps.dat"
_F_SORT "data/svcs.dat"
_F_SORT "data/svc_saps.dat"
_F_SORT "data/svc_sdps.dat"
_F_SORT "data/svc_fdbs.dat"
_F_SORT "data/bundles.dat"
_F_SORT "data/apss.dat"
_F_SORT "data/lags.dat"
_F_SORT "data/ports.dat"
_F_SORT "data/monitors.dat"
_F_SORT "data/ports-power.dat"
_F_SORT "data/svc_endpoints.dat"
_F_SORT "data/svc_interfaces.dat"
_F_SORT "data/svc_arps.dat"
_F_SORT "data/svc_vrrps.dat"
_F_SORT "data/svc_statics.dat"
_F_SORT "data/lsa.dat"