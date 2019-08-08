#!/bin/bash

cp nodes.ini nodes.lst
rm -rf temp/basicdata 2> /dev/null
rm -rf temp/operdata 2> /dev/null
rm -rf data/* 2> /dev/null
touch data/nodes.dat
touch data/ospf_neighbors.dat
touch data/temps.dat
touch data/cards.dat
touch data/mdas.dat
touch data/fans.dat
touch data/syncs.dat
touch data/ptps.dat
touch data/ptp-peers.dat
touch data/pems.dat
touch data/ints.dat
touch data/ospf_ints.dat
touch data/bgp_neis.dat
touch data/paths.dat
touch data/lsps.dat
touch data/sdps.dat
touch data/svcs.dat
touch data/svc_saps.dat
touch data/svc_sdps.dat
touch data/svc_fdbs.dat
touch data/bundles.dat
touch data/apss.dat
touch data/lags.dat
touch data/ports.dat
touch data/monitors.dat
touch data/ports-power.dat
touch data/svc_endpoints.dat
touch data/svc_interfaces.dat
touch data/svc_arps.dat
touch data/svc_vrrps.dat
touch data/svc_statics.dat
touch data/lsa.dat

rm fail.lst 2> /dev/null
touch fail.lst
rm errors.log 2> /dev/null
touch errors.log
mkdir temp/basicdata
mkdir temp/operdata