#!/bin/bash

_F_PWR2(){
	__RES=1
	__PWR=$1
	while [ $__PWR -gt 0 ]; do
		let __RES=$__RES*2
		let __PWR-=1
	done
	echo "$__RES"
}

_F_NET_ADD(){
	let __D1=$(echo $1 | tr "." "\n" | head -1 | tail -1)
	let __D2=$(echo $1 | tr "." "\n" | head -2 | tail -1)
	let __D3=$(echo $1 | tr "." "\n" | head -3 | tail -1)
	let __D4=$(echo $1 | tr "." "\n" | head -4 | tail -1)
	let __BH=32-$2
	let __DT=($__D4+$__D3*$(_F_PWR2 8)+$__D2*$(_F_PWR2 16)+$__D1*$(_F_PWR2 24))/$(_F_PWR2 $__BH)*$(_F_PWR2 $__BH)
	let __D1R=($__DT/$(_F_PWR2 24))
	let __D2R=($__DT-$__D1R*$(_F_PWR2 24))/$(_F_PWR2 16)
	let __D3R=($__DT-$__D1R*$(_F_PWR2 24)-$__D2R*$(_F_PWR2 16))/$(_F_PWR2 8)
	let __D4R=($__DT-$__D1R*$(_F_PWR2 24)-$__D2R*$(_F_PWR2 16)-$__D3R*$(_F_PWR2 8))
	echo "$__D1R.$__D2R.$__D3R.$__D4R"
}

_I_MAX=29

_C[1]="show system information"
_C[2]="admin display-config | match post-lines 1 admin"
_C[3]="show system cpu | match dle"
_C[4]="show system memory-pools | match Available"
_C[5]="show router ospf neighbor detail"
_C[6]="show card detail"
_C[7]="show mda detail"
_C[8]="show chassis"
_C[9]="show system sync-if-timing"
_C[10]="show system ptp clock 1 detail"
_C[11]="show system ptp clock 1 summary"
_C[12]="show router interface detail"
_C[13]="show router ospf interface detail"
_C[14]="show router bgp neighbor"
_C[15]="show router mpls path"
_C[16]="show router mpls lsp detail"
_C[17]="show router mpls lsp path detail"
_C[18]="show service sdp detail"
_C[19]="show service service-using"
_C[20]="show service sap-using"
_C[21]="show service sdp-using"
_C[22]="show service fdb-mac"
_C[23]="show multilink-bundle detail"
_C[24]="show aps detail"
_C[25]="show lag detail"
_C[26]="show port"
_C[27]="show router ospf database | match LSA"
_C[28]="show router mpls status"
_C[29]="admin display-config"

_CG=""
for (( _i_cmd=1; _i_cmd<=$_I_MAX; _i_cmd++ )); do 
  _CG=$(echo -e "$_CG\r${_C[$_i_cmd]}"); 
  done

_IP_NODE=$1
_TF="temp/basicdata/$_IP_NODE.tmp"
_STATUS=$(./sender.bash $_IP_NODE "$_CG" $_TF)
if (( $_STATUS > 0 )); then
  for (( _i_cmd=1; _i_cmd<=$_I_MAX; _i_cmd++ )); do
    _P[$_i_cmd]=$(cat $_TF | grep -n "${_C[$_i_cmd]}" | tr ":" "\n" | head -1) 
  done
  _P[$_i_cmd]=$(cat $_TF | wc -l)
  _PT=$(cat $_TF | wc -l)
  _i_cmd=1
  
  #_C[1]="show system information"
  # SYSTEM INFO
  # echo "$_IP_NODE:SYSTEM INFO" >> errors.log
  _NODE_NAME=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "System Name" | tr ":" "\n" | tail -1 | sed 's/ //g' | tr -d "\r" | col -bx)
  _NODE_TYPE=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "System Type" | tr ":" "\n" | tail -1 | sed 's/ //g' | tr -d "\r" | col -bx)
  _NODE_SOFT=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "System Version" | tr ":" "\n" | tail -1 | sed 's/ //g' | tr -d "\r" | col -bx)
  _NODE_UP_DAYS=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "System Up Time" | tr "(" "\n" | head -1 | tr "," "\n" | head -1 | tr ":" "\n" | tail -1 | tr "d" "\n" | head -1 | sed 's/ //g' | tr -d "\r" | col -bx)
  _NODE_UP_TIME=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "System Up Time" | tr "(" "\n" | head -1 | tr "," "\n" | tail -1 | sed 's/ //g' | tr -d "\r" | col -bx)
  _MNGT_ADD=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Management IP Addr" | tr ":" "\n" | tail -1 | sed 's/ //g' | tr -d "\r" | col -bx)
  let _i_cmd+=1
  
  #_C[2]="admin display-config | match post-lines 1 admin"
  # SYSTEM USER
  if (( $(cat $_TF | grep ".wwBSCf55BeJQsICA8BrJ." | wc -l) > 0 )); then 
    _IMPL_STATUS="NEW"; else _IMPL_STATUS="SAM" 
  fi
  let _i_cmd+=1
  
  #_C[3]="show system cpu | match dle"
  # SYSTEM CPU
  _IDLE_CPU=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Idle" | awk '{print $3}' | sed 's/ //g' | tr -d "\r" | col -bx)
  let _i_cmd+=1
  
  #_C[4]="show system memory-pools | match Available"
  #SYSTEM MEMORY
  _IDLE_MEMORY=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Memory" | tr ":" "\n" | tail -1 | sed 's/ //g' | tr "b" "\n" | head -1 | tr "," "." | tr -d "\r" | col -bx)
  let _i_cmd+=1

  #_C[5]="show router ospf neighbor detail"
  if (( $(cat "data/nodes.dat" 2> /dev/null | grep "$_IP_NODE;$_NODE_NAME;$_NODE_TYPE;" | wc -l) < 1 )); then  
    echo "$_IP_NODE;$_NODE_NAME;$_NODE_TYPE;$_NODE_SOFT;$_MNGT_ADD;$_NODE_UP_DAYS;$_NODE_UP_TIME;$_IDLE_CPU;$_IDLE_MEMORY;$_IMPL_STATUS" >> "data/nodes.dat"
  fi

  # OSPF NEIGHBOR LIST
  # echo "$_IP_NODE:OSPF NEIGHBOR" >> errors.log
  _n_nei=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Rtr Id :" | wc -l | tr -d "\r" | col -bx | sed 's/ //g')
  for (( _i_nei=1; _i_nei<=_n_nei; _i_nei++ )); do
    _IP_VEC=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Rtr Id :" | head -$_i_nei | tail -1 | cut -c 19- | tr " " "\n" | head -1 | sed 's/ //g' | tr -d "\r" | col -bx)
	_AREA_ID=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Area Id" | head -$_i_nei | tail -1 | awk '{print $4}' | sed 's/ //g' | tr -d "\r" | col -bx)
	_NEI_STATE=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Neighbor State" | head -$_i_nei | tail -1 | awk '{print $4}' | sed 's/ //g' | tr -d "\r" | col -bx)
	_LOC_IP=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Local IF IP Addr" | head -$_i_nei | tail -1 | awk '{print $6}' | sed 's/ //g' | tr -d "\r" | col -bx)
	_REM_IP=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Neighbor IP Addr" | head -$_i_nei | tail -1 | awk '{print $5}' | sed 's/ //g' | tr -d "\r" | col -bx)
	_LOC_INT=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Rtr Id :" | head -$_i_nei | tail -1 | tr ":" "\n" | tail -1 | sed 's/ //g' | tr -d "\r" | col -bx)
    if (( $(cat nodes.lst | grep "$_IP_VEC;" | wc -l) < 1 )); then
      echo "$_IP_VEC;" >> nodes.lst
      if (( $(./ping.bash $_IP_VEC)>0 )); then
        ./basicdata.bash $_IP_VEC $2 &
      fi
    fi
	if (( $(cat "data/ospf_neighbors.dat" 2> /dev/null | grep "$_IP_NODE;$_IP_VEC;" | wc -l) < 1 )); then
      echo "$_IP_NODE;$_IP_VEC;$_AREA_ID;$_NEI_STATE;$_LOC_INT;$_LOC_IP;$_REM_IP" >> data/ospf_neighbors.dat
	fi
  done
  let _i_cmd+=1

  #_C[6]="show card detail"
  # SYSTEM TEMPERATURE & CARD INFO
  # echo "$_IP_NODE:SYSTEM TEMPERATURE & CARD INFO" >> errors.log
  _n_card=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Card " | grep -v IOM | grep -v Model | wc -l)
  for (( _i_card=1; _i_card<=_n_card; _i_card++ )); do
    _CARD_ID=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Card " | grep -v IOM | grep -v Model | head -$_i_card | tail -1 | awk '{print $2}' | sed 's/ //g' | tr -d "\r" | col -bx)
    _TEMP=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep Temperature | grep -v threshold | head -$_i_card | tail -1 | tr ":" "\n" | tail -1 | sed 's/ //g' | tr -d "\r" | col -bx)
	_TEMP_TH=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Temperature threshold" | head -$_i_card | tail -1 | tr ":" "\n" | tail -1 | sed 's/ //g' | tr -d "\r" | col -bx)
	
	_PN_CARD=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Part number" | head -$_i_card | tail -1 | tr ":" "\n" | tail -1 | sed 's/ //g' | tr -d "\r" | col -bx)
	_SN_CARD=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Serial number" | head -$_i_card | tail -1 | tr ":" "\n" | tail -1 | sed 's/ //g' | tr -d "\r" | col -bx)
	_SWFW_CARD=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Software boot" | head -$_i_card | tail -1 | awk '{print $6}' | sed 's/ //g' | tr -d "\r" | col -bx)
	_BOOT_Y_CARD=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Time of last boot" | head -$_i_card | tail -1 | awk '{print $6}' | tr -d "\r" | col -bx)
	_BOOT_T_CARD=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Time of last boot" | head -$_i_card | tail -1 | awk '{print $7}' | tr -d "\r" | col -bx)
	
	_P_CARD=$(cat -n $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Card-type" | head -$_i_card | tail -1 | awk '{print $1}' | sed 's/ //g' | tr -d "\r" | col -bx)
	_OPE_STATE=$(cat $_TF | head -$(($_P_CARD+2)) | tail -1 | awk '{print $5}' | sed 's/ //g' | tr -d "\r" | col -bx)
	if (( $(echo $_OPE_STATE | wc -c) < 2 )); then
	  _ADM_STATE=$(cat $_TF | head -$(($_P_CARD+2)) | tail -1 | awk '{print $3}' | sed 's/ //g' | tr -d "\r" | col -bx)
	  _OPE_STATE=$(cat $_TF | head -$(($_P_CARD+2)) | tail -1 | awk '{print $4}' | sed 's/ //g' | tr -d "\r" | col -bx)
	  _PROV_CARD=$(cat $_TF | head -$(($_P_CARD+2)) | tail -1 | awk '{print $2}' | sed 's/ //g' | tr -d "\r" | col -bx)
	  _EQUI_CARD=""
    else
	  _ADM_STATE=$(cat $_TF | head -$(($_P_CARD+2)) | tail -1 | awk '{print $4}' | sed 's/ //g' | tr -d "\r" | col -bx)
	  _PROV_CARD=$(cat $_TF | head -$(($_P_CARD+2)) | tail -1 | awk '{print $2}' | sed 's/ //g' | tr -d "\r" | col -bx)
	  _EQUI_CARD=$(cat $_TF | head -$(($_P_CARD+2)) | tail -1 | awk '{print $3}' | sed 's/ //g' | tr -d "\r" | col -bx)
	fi
	
	if (( $(echo $_TEMP | grep "n\/a" | wc -l) < 1 )); then
      if (( $(cat "data/temps.dat" 2> /dev/null | grep "$_IP_NODE;$_CARD_ID;" | wc -l) < 1 )); then
        echo "$_IP_NODE;$_CARD_ID;$_TEMP;$_TEMP_TH" >> data/temps.dat
	  fi
    fi
	if (( $(cat "data/cards.dat" 2> /dev/null | grep "$_IP_NODE;$_CARD_ID;" | wc -l) < 1 )); then
      echo "$_IP_NODE;$_CARD_ID;$_PROV_CARD;$_EQUI_CARD;$_ADM_STATE;$_OPE_STATE;$_PN_CARD;$_SN_CARD;$_SWFW_CARD;$_BOOT_Y_CARD;$_BOOT_T_CARD" >> data/cards.dat
	fi
  done
  let _i_cmd+=1
  
  #_C[7]="show mda detail"
  # MDA INFO
  # echo "$_IP_NODE:MDA INFO" >> errors.log
  _n_mda=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep MDA | grep detail | wc -l)
  for (( _i_mda=1; _i_mda<=_n_mda; _i_mda++ )); do
    _MDA_ID=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep MDA | grep detail | head -$_i_mda | tail -1 | awk '{print $2}' | sed 's/ //g' | tr -d "\r" | col -bx)

	_PN_MDA=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Part number" | head -$_i_mda | tail -1 | tr ":" "\n" | tail -1 | sed 's/ //g' | tr -d "\r" | col -bx)
	_SN_MDA=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Serial number" | head -$_i_mda | tail -1 | tr ":" "\n" | tail -1 | sed 's/ //g' | tr -d "\r" | col -bx)
	_BOOT_Y_MDA=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Time of last boot" | head -$_i_mda | tail -1 | awk '{print $6}' | tr -d "\r" | col -bx)
	_BOOT_T_MDA=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Time of last boot" | head -$_i_mda | tail -1 | awk '{print $7}' | tr -d "\r" | col -bx)
	
	_P_MDA=$(cat -n $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Mda-type" | head -$_i_mda | tail -1 | awk '{print $1}' | sed 's/ //g' | tr -d "\r" | col -bx)
	if (( $(cat $_TF | head -$(($_P_MDA+2)) | tail -1 | cut -c1 | sed 's/ //g' | wc -c) > 1 )); then
	  _OPE_STATE=$(cat $_TF | head -$(($_P_MDA+2)) | tail -1 | awk '{print $6}' | sed 's/ //g' | tr -d "\r" | col -bx)
	  if (( $(echo $_OPE_STATE | wc -c) < 2 )); then
	    _OPE_STATE=$(cat $_TF | head -$(($_P_MDA+2)) | tail -1 | awk '{print $5}' | sed 's/ //g' | tr -d "\r" | col -bx)
	    _PROV_MDA=$(cat $_TF | head -$(($_P_MDA+2)) | tail -1 | awk '{print $3}' | sed 's/ //g' | tr -d "\r" | col -bx)
	    _EQUI_MDA=""
	    _ADM_STATE=$(cat $_TF | head -$(($_P_MDA+2)) | tail -1 | awk '{print $4}' | sed 's/ //g' | tr -d "\r" | col -bx)
	  else
	    _PROV_MDA=$(cat $_TF | head -$(($_P_MDA+2)) | tail -1 | awk '{print $3}' | sed 's/ //g' | tr -d "\r" | col -bx)
	    _EQUI_MDA=$(cat $_TF | head -$(($_P_MDA+2)) | tail -1 | awk '{print $4}' | sed 's/ //g' | tr -d "\r" | col -bx)
	    _ADM_STATE=$(cat $_TF | head -$(($_P_MDA+2)) | tail -1 | awk '{print $5}' | sed 's/ //g' | tr -d "\r" | col -bx)
	  fi
	else
	  _OPE_STATE=$(cat $_TF | head -$(($_P_MDA+2)) | tail -1 | awk '{print $5}' | sed 's/ //g' | tr -d "\r" | col -bx)
	  if (( $(echo $_OPE_STATE | wc -c) < 2 )); then
	    _OPE_STATE=$(cat $_TF | head -$(($_P_MDA+2)) | tail -1 | awk '{print $4}' | sed 's/ //g' | tr -d "\r" | col -bx)
	    _PROV_MDA=$(cat $_TF | head -$(($_P_MDA+2)) | tail -1 | awk '{print $2}' | sed 's/ //g' | tr -d "\r" | col -bx)
	    _EQUI_MDA=""
	    _ADM_STATE=$(cat $_TF | head -$(($_P_MDA+2)) | tail -1 | awk '{print $3}' | sed 's/ //g' | tr -d "\r" | col -bx)
	  else
	    _PROV_MDA=$(cat $_TF | head -$(($_P_MDA+2)) | tail -1 | awk '{print $2}' | sed 's/ //g' | tr -d "\r" | col -bx)
	    _EQUI_MDA=$(cat $_TF | head -$(($_P_MDA+2)) | tail -1 | awk '{print $3}' | sed 's/ //g' | tr -d "\r" | col -bx)
	    _ADM_STATE=$(cat $_TF | head -$(($_P_MDA+2)) | tail -1 | awk '{print $4}' | sed 's/ //g' | tr -d "\r" | col -bx)
	  fi
	fi
		
	if (( $(cat "data/mdas.dat" 2> /dev/null | grep "$_IP_NODE;$_MDA_ID;" | wc -l) < 1 )); then
      echo "$_IP_NODE;$_MDA_ID;$_PROV_MDA;$_EQUI_MDA;$_ADM_STATE;$_OPE_STATE;$_PN_MDA;$_SN_MDA;$_BOOT_Y_MDA;$_BOOT_T_MDA" >> data/mdas.dat
	fi
  done
  let _i_cmd+=1
   
  #_C[8]="show chassis"   
  _ini_fan=$(cat -n $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep Environment | awk '{print $1}' | head -1 | sed 's/ //g' | tr -d "\r" | col -bx)
  _ini_pem=$(cat -n $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep Power | grep Information | awk '{print $1}' | head -1 | sed 's/ //g' | tr -d "\r" | col -bx)
  _fin=$(cat -n $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | tail -1 | awk '{print $1}' | sed 's/ //g' | tr -d "\r" | col -bx)
  
  # FANS STATUS
  # echo "$_IP_NODE:FANS INFO" >> errors.log
  _n_fans=$(cat $_TF | tail -$(($_PT-$_ini_fan+1)) | head -$(($_ini_pem-$_ini_fan)) | grep "Status" | wc -l)
  for (( _i_fans=1; _i_fans<=$_n_fans; _i_fans++ )); do
    _status_fan=$(cat $_TF | tail -$(($_PT-$_ini_fan+1)) | head -$(($_ini_pem-$_ini_fan)) | grep "Status" | head -$_i_fans  | tail -1 | tr ":" "\n" | tail -1 | sed 's/ //g' | tr -d "\r" | col -bx)
    _speed_fan=$(cat $_TF | tail -$(($_PT-$_ini_fan+1)) | head -$(($_ini_pem-$_ini_fan)) | grep "Speed" | head -$_i_fans  | tail -1 | tr ":" "\n" | tail -1 | sed 's/ //g' | tr -d "\r" | col -bx)
	
    if (( $(cat "data/fans.dat" 2> /dev/null | grep "$_IP_NODE;$_i_fans;" | wc -l) < 1 )); then
      echo "$_IP_NODE;$_i_fans;$_status_fan;$_speed_fan" >> data/fans.dat
    fi
  done

#=============================================
#agregado 2017-05-31
#=============================================
#Chassis Serial Number


  _ini_chassis=$(cat -n $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Chassis Information" | awk '{print $1}' | head -1 | sed 's/ //g' | tr -d "\r" | col -bx)  
  _fin_chassis=$(cat -n $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Environment Information" | awk '{print $1}' | head -1 | sed 's/ //g' | tr -d "\r" | col -bx)  
  _SN_chassis=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Serial number" | awk '{print $4}' | head -1 | sed 's/ //g' | tr -d "\r" | col -bx)  
  if (( $(cat "data/SerialNumber.dat" 2> /dev/null | grep "$_IP_NODE;$_SN_chassis" | wc -l) < 1 )); then   
    echo "$_IP_NODE;$_SN_chassis" >> data/SerialNumber.dat
  fi 


#_SN_Chassis=$(cat $_TF | tail -$(($_PT-$_ini_fan+1)) | head -$(($_ini_pem-$_ini_fan)) | grep "Serial number"  | head -1 )
#  if (( $(cat "data/SerialNumber.dat" 2> /dev/null | grep "$_IP_NODE;$_SN_Chassis;" | wc -l) < 1 )); then   
#    echo "$_IP_NODE;$_SN_Chassis" >> data/SerialNumber.dat
#  fi 
#=============================================
  
  # POWER STATUS
  # echo "$_IP_NODE:POWER INFO" >> errors.log
  _n_pems=$(cat $_TF | tail -$(($_PT-$_ini_pem+1)) | head -$(($_fin-$_ini_pem)) | grep "Status" | wc -l)
  for (( _i_pems=1; _i_pems<=$_n_pems; _i_pems++ )); do
    _model_pem=$(cat $_TF | tail -$(($_PT-$_ini_pem+1)) | head -$(($_fin-$_ini_pem)) | grep "Number of power" | awk '{print $4}' | sed 's/ //g' | tr -d "\r" | col -bx)
    _type_pem=$(cat $_TF | tail -$(($_PT-$_ini_pem+1)) | head -$(($_fin-$_ini_pem)) | grep -i "type" | head -$_i_pems | tail -1 | tr ":" "\n" | tail -1 | sed 's/ //g' | tr -d "\r" | col -bx)
    _status_pem=$(cat $_TF | tail -$(($_PT-$_ini_pem+1)) | head -$(($_fin-$_ini_pem)) | grep "Status" | head -$_i_pems | tail -1 | tr ":" "\n" | tail -1 | sed 's/ //g' | tr -d "\r" | col -bx)
	
    if (( $(cat "data/pems.dat" 2> /dev/null | grep "$_IP_NODE;$_i_pems;" | wc -l) < 1 )); then
      echo "$_IP_NODE;$_i_pems;$_model_pem;$_type_pem;$_status_pem" >> data/pems.dat
    fi
  done
  let _i_cmd+=1
  
  #_C[9]="show system sync-if-timing"
  # SYNC CONFIG
  # echo "$_IP_NODE:SYNC INFO" >> errors.log
  if (( $(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "System Status" | wc -l) > 0 )); then
    _SYNC_STATUS=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "System Status" | tr ":" "\n" | tail -1 | sed 's/ //g' | tr -d "\r" | col -bx)
    _SYNC_ORDER=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Reference Order" | awk '{print $4 "-" $5 "-" $6}' | sed 's/ //g' | tr -d "\r" | col -bx)
    _REF1_STATUS=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Admin Status" | head -1 | awk '{print $4}' | sed 's/ //g' | tr -d "\r" | col -bx)
    _REF1_QFU=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Qualified For Use" | head -1 | tail -1 | awk '{print $5}' | sed 's/ //g' | tr -d "\r" | col -bx)
    _REF1_USED=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Selected For Use" | head -1 | tail -1 | awk '{print $5}' | sed 's/ //g' | tr -d "\r" | col -bx)
    _P_REF1=$(cat -n $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Source Port" | head -1 | tail -1 | awk '{print $1}' | sed 's/ //g' | tr -d "\r" | col -bx)
    if (( $(cat $_TF | head -$(($_P_REF1+1)) | tail -1 | grep "PTP" | wc -l) > 0 )); then
      _REF1_TYPE="PTP"
	  _REF1_INPUT=$(cat $_TF | head -$(($_P_REF1+1)) | tail -1 | tr ":" "\n" | tail -1 | sed 's/ //g' | tr -d "\r" | col -bx)
    else
      _REF1_TYPE="PORT"
	  _REF1_INPUT=$(cat $_TF | head -$_P_REF1 | tail -1 | tr ":" "\n" | tail -1 | sed 's/ //g' | tr -d "\r" | col -bx)
    fi
    _REF2_STATUS=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Admin Status" | head -2 | tail -1 | awk '{print $4}' | sed 's/ //g' | tr -d "\r" | col -bx)
    _REF2_QFU=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Qualified For Use" | head -2 | tail -1 | awk '{print $5}' | sed 's/ //g' | tr -d "\r" | col -bx)
    _REF2_USED=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Selected For Use" | head -2 | tail -1 | awk '{print $5}' | sed 's/ //g' | tr -d "\r" | col -bx)
    _P_REF2=$(cat -n $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Source Port" | head -2 | tail -1 | awk '{print $1}' | sed 's/ //g' | tr -d "\r" | col -bx)
    if (( $(cat $_TF | head -$(($_P_REF2+1)) | tail -1 | grep "PTP" | wc -l) > 0 )); then
      _REF2_TYPE="PTP"
	  _REF2_INPUT=$(cat $_TF | head -$(($_P_REF2+1)) | tail -1 | tr ":" "\n" | tail -1 | sed 's/ //g' | tr -d "\r" | col -bx)
    else
      _REF2_TYPE="PORT"
	  _REF2_INPUT=$(cat $_TF | head -$_P_REF2 | tail -1 | tr ":" "\n" | tail -1 | sed 's/ //g' | tr -d "\r" | col -bx)
    fi
    _REFEXT_STATUS=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Admin Status" | head -3 | tail -1 | awk '{print $4}' | sed 's/ //g' | tr -d "\r" | col -bx)
    _REFEXT_QFU=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Qualified For Use" | head -3 | tail -1 | awk '{print $5}' | sed 's/ //g' | tr -d "\r" | col -bx)
    _REFEXT_USED=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Selected For Use" | head -3 | tail -1 | awk '{print $5}' | sed 's/ //g' | tr -d "\r" | col -bx)
  
    if (( $(cat "data/syncs.dat" 2> /dev/null | grep "$_IP_NODE;" | wc -l) < 1 )); then
      echo "$_IP_NODE;$_SYNC_STATUS;$_SYNC_ORDER;$_REF1_STATUS;$_REF1_QFU;$_REF1_USED;$_REF1_TYPE;$_REF1_INPUT;$_REF2_STATUS;$_REF2_QFU;$_REF2_USED;$_REF2_TYPE;$_REF2_INPUT;$_REFEXT_STATUS;$_REFEXT_QFU;$_REFEXT_USED" >> data/syncs.dat
    fi
  fi
  let _i_cmd+=1
  
  #_C[10]="show system ptp clock 1 detail"
  # PTP CONFIG
  # echo "$_IP_NODE:PTP INFO" >> errors.log
  if (( $(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Clock Type" | wc -l) > 0 )); then
    _PTP_TYPE=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Clock Type" | tr ":" "\n" | head -2 | tail -1 | awk '{print $1}' | sed 's/ //g' | tr -d "\r" | col -bx)
    _PTP_SOURCE=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Admin Freq-source" | tr ":" "\n" | head -2 | tail -1 | awk '{print $1}' | sed 's/ //g' | tr -d "\r" | col -bx)
    _PTP_INT=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Source IP Interface" | tr ":" "\n" | head -2 | tail -1 | awk '{print $1}' | sed 's/ //g' | tr -d "\r" | col -bx)
    _PTP_ADM_STATUS=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Admin Status" | head -1 | tr ":" "\n" | head -2 | tail -1 | awk '{print $1}' | sed 's/ //g' | tr -d "\r" | col -bx)
    _PTP_OPE_STATUS=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Oper Status" | tr ":" "\n" | tail -1 | sed 's/ //g' | tr -d "\r" | col -bx)
  
    if (( $(cat "data/ptps.dat" 2> /dev/null | grep "$_IP_NODE;" | wc -l) < 1 )); then
      echo "$_IP_NODE;$_PTP_TYPE;$_PTP_SOURCE;$_PTP_INT;$_PTP_ADM_STATUS;$_PTP_OPE_STATUS" >> data/ptps.dat
    fi
  fi
  let _i_cmd+=1

  #_C[11]="show system ptp clock 1 summary"
  # PTP PEER
  # echo "$_IP_NODE:PTP PEER INFO" >> errors.log
  if (( $(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "State" | wc -l) > 0 )); then
    _PI_PTP=$(($(cat -n $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "State" | tail -1 | awk '{print $1}' | tr -d "\t" | col -bx | sed 's/ //g')+2))
    _PF_PTP=$(($(cat -n $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Unicast" | tail -1 | awk '{print $1}' | tr -d "\t" | col -bx | sed 's/ //g')-2))
    _n_ptp_peers=$(cat $_TF | tail -$(($_PT-$_PI_PTP+1)) | head -$(($_PF_PTP-$_PI_PTP)) | grep "sta in" | wc -l | tr -d "\t" | col -bx | sed 's/ //g')
    for (( _i_ptp_peers=1; _i_ptp_peers<=$_n_ptp_peers; _i_ptp_peers++ )); do
	  _P_PTP=$(cat -n $_TF | tail -$(($_PT-$_PI_PTP+1)) | head -$(($_PF_PTP-$_PI_PTP)) | grep "sta in" | head -$_i_ptp_peers | tail -1 | awk '{print $1}' | tr -d "\t" | col -bx | sed 's/ //g')
      if (( $(cat $_TF | head -$_P_PTP | tail -1 | awk '{print $5}' | grep "sta" | wc -l) > 0 )); then
	    _PTP_PEER_ID=$(cat $_TF | head -$_P_PTP | tail -1 | awk '{print $1}' | sed 's/ //g' | tr -d "\r" | col -bx)
	    _PTP_PEER_ADD=$(cat $_TF | head -$_P_PTP | tail -1 | awk '{print $2}' | sed 's/ //g' | tr -d "\r" | col -bx)
	    _PTP_PEER_SLAVE=$(cat $_TF | head -$_P_PTP | tail -1 | awk '{print $3}' | sed 's/ //g' | tr -d "\r" | col -bx)
	    _PTP_PEER_STATE=$(cat $_TF | head -$_P_PTP | tail -1 | awk '{print $4}' | sed 's/ //g' | tr -d "\r" | col -bx)
	    
	    if (( $(cat "data/ptp-peers.dat" 2> /dev/null | grep "$_IP_NODE;$_PTP_PEER_ID" | wc -l) < 1 )); then
          echo "$_IP_NODE;$_PTP_PEER_ID;$_PTP_PEER_ADD;$_PTP_PEER_SLAVE;$_PTP_PEER_STATE" >> data/ptp-peers.dat
        fi
	  fi
    done
  fi
  let _i_cmd+=1
  
  #_C[12]="show router interface detail"
  # BASE INTERFACES
  # echo "$_IP_NODE:BASE INTERFACES" >> errors.log
  _n_ints=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "If Name" | wc -l)
  for (( _i_ints=1; _i_ints<=$_n_ints; _i_ints++ )); do
    _PI_INT=$(cat -n $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "If Name" | head -$_i_ints | tail -1 | awk '{print $1}' | tr -d "\t" | col -bx | sed 's/ //g')
	if (( $_i_ints < $_n_ints )); then
	  _PF_INT=$(($(cat -n $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "If Name" | head -$(($_i_ints+1)) | tail -1 | awk '{print $1}' | tr -d "\t" | col -bx | sed 's/ //g')-1))
	else
	  _PF_INT=$((${_P[$_i_cmd+1]}-1))
	fi
	
    _INT_NAME=$(cat $_TF | tail -$(($_PT-$_PI_INT+1)) | head -$(($_PF_INT-$_PI_INT+1)) | grep "If Name" | tail -1 | tr ":" "\n" | tail -1 | cut -c 2- | sed 's/ //g' | tr -d "\r" | col -bx)
	_INT_IP=$(cat $_TF | tail -$(($_PT-$_PI_INT+1)) | head -$(($_PF_INT-$_PI_INT+1)) | grep "IP Addr\/mask" | tail -1 | awk '{print $4}' | tr "/" "\n" | head -1 | tr -d "\r" | col -bx)
	_INT_MASK=$(cat $_TF | tail -$(($_PT-$_PI_INT+1)) | head -$(($_PF_INT-$_PI_INT+1)) | grep "IP Addr\/mask" | tail -1 | awk '{print $4}' | tr "/" "\n" | head -2 | tail -1 | tr -d "\r" | col -bx)
	_INT_TYPE=$(cat $_TF | tail -$(($_PT-$_PI_INT+1)) | head -$(($_PF_INT-$_PI_INT+1)) | grep "If Type" | tail -1 | tr ":" "\n" | tail -1 | sed 's/ //g' | tr -d "\r" | col -bx)
	_INT_ADM_S=$(cat $_TF | tail -$(($_PT-$_PI_INT+1)) | head -$(($_PF_INT-$_PI_INT+1)) | grep "Admin State" | grep "Oper" | tail -1 | awk '{print $4}' | tr -d "\r" | col -bx)
	_INT_OPE_S=$(cat $_TF | tail -$(($_PT-$_PI_INT+1)) | head -$(($_PF_INT-$_PI_INT+1)) | grep "Admin State" | grep "Oper" | tail -1 | tr ":" "\n" | tail -1 | tr "/" "\n" | head -1 | sed 's/ //g' | tr -d "\r" | col -bx)
	_INT_PORT=$(cat $_TF | tail -$(($_PT-$_PI_INT+1)) | head -$(($_PF_INT-$_PI_INT+1)) | grep "Port Id" | awk '{print $4}' | tr -d "\r" | col -bx)
	if (( $(echo $_INT_PORT | wc -c) < 2 )); then
	  _INT_PORT=$(cat $_TF | tail -$(($_PT-$_PI_INT+1)) | head -$(($_PF_INT-$_PI_INT+1)) | grep "SAP Id" | awk '{print $4}' | tr -d "\r" | col -bx)
	fi
	if (( $(echo $_INT_PORT | grep rvpls | wc -l) > 0 )); then
	  _INT_PORT=$(cat $_TF | tail -$(($_PT-$_PI_INT+1)) | head -$(($_PF_INT-$_PI_INT+1)) | grep "VPLS Name" | awk '{print $4}' | tr -d "\r" | col -bx)
	fi
	if (( $(echo $_INT_PORT | grep ":" | wc -l) > 0 )); then 
	  _PORT_VID=$(echo $_INT_PORT | tr ":" "\n" | tail -1 | tr -d "\r" | col -bx)
	else 
	  _PORT_VID="N/A"
	fi
	_PORT_ID=$(echo $_INT_PORT | tr ":" "\n" | head -1 | tr -d "\r" | col -bx)
	
    if (( $(cat "data/ints.dat" 2> /dev/null | grep "$_IP_NODE;$_INT_NAME;" | wc -l) < 1 )); then
	  echo "$_IP_NODE;$_INT_NAME;$_INT_IP;$_INT_MASK;$_PORT_ID;$_PORT_VID;$_INT_TYPE;$_INT_ADM_S;$_INT_OPE_S;$(_F_NET_ADD $_INT_IP $_INT_MASK)" >> data/ints.dat
    fi
  done
  let _i_cmd+=1
  
  #_C[13]="show router ospf interface detail"
  # BASE OSPF CONFIG
  # echo "$_IP_NODE:BASE OSPF" >> errors.log
  _n_ospf=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Interface :" | wc -l)
  for (( _i_ospf=1; _i_ospf<=$_n_ospf; _i_ospf++ )); do
	_INT_NAME=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Interface :" | head -$_i_ospf | tail -1 | tr ":" "\n" | tail -1 | cut -c 2- | tr -d "\r" | col -bx)
	_OSPF_AREA=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Area Id" | head -$_i_ospf | tail -1 | awk '{print $4}' | tr -d "\r" | col -bx)
	_OSPF_TYPE=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "IF Type" | head -$_i_ospf | tail -1 | awk '{print $4}' | tr -d "\r" | col -bx)
	_OSPF_METRIC=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Cfg Metric" | head -$_i_ospf | tail -1 | awk '{print $4}' | tr -d "\r" | col -bx)
	
    if (( $(cat "data/ospf_ints.dat" 2> /dev/null | grep "$_IP_NODE;$_INT_NAME;" | wc -l) < 1 )); then
	  echo "$_IP_NODE;$_INT_NAME;$_OSPF_AREA;$_OSPF_TYPE;$_OSPF_METRIC" >> data/ospf_ints.dat
    fi
  done
  let _i_cmd+=1
	
  #_C[14]="show router bgp neighbor"	
  # BASE BGP CONFIG
  # echo "$_IP_NODE:BASE BGP" >> errors.log
  _n_bgp_neis=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Peer Address" | wc -l)
  for (( _i_bgp_neis=1; _i_bgp_neis<=$_n_bgp_neis; _i_bgp_neis++ )); do
	_BGP_PEER_ADD=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Peer Address" | head -$_i_bgp_neis | tail -1 | awk '{print $4}' | sed 's/ //g' | tr -d "\r" | col -bx)
	_BGP_PEER_STATE=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "State" | head -$_i_bgp_neis | tail -1 | awk '{print $3}' | sed 's/ //g' | tr -d "\r" | col -bx)
	_BGP_LOCAL_FAMILY=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Local Family" | head -$_i_bgp_neis | tail -1 | awk '{print $4}' | sed 's/ //g' | tr -d "\r" | col -bx)
	_BGP_PEER_FAMILY=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Remote Family" | head -$_i_bgp_neis | tail -1 | awk '{print $4}' | sed 's/ //g' | tr -d "\r" | col -bx)
	_BGP_LOCAL_AS=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Local AS" | head -$_i_bgp_neis | tail -1 | awk '{print $4}' | sed 's/ //g' | tr -d "\r" | col -bx)
	_BGP_PEER_AS=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Peer AS" | head -$_i_bgp_neis | tail -1 | awk '{print $4}' | sed 's/ //g' | tr -d "\r" | col -bx)
	_BGP_PEER_CLUSTER=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Cluster Id" | head -$_i_bgp_neis | tail -1 | awk '{print $4}' | sed 's/ //g' | tr -d "\r" | col -bx)
	_BGP_PEER_GROUP=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Group" | head -$_i_bgp_neis | tail -1 | tr ":" "\n" | tail -1 | sed 's/ //g' | tr -d "\r" | col -bx)
	  
	if (( $(cat "data/bgp_neis.dat" 2> /dev/null | grep "$_IP_NODE;$_BGP_PEER_ADD" | wc -l) < 1 )); then
      echo "$_IP_NODE;$_BGP_PEER_ADD;$_BGP_PEER_STATE;$_BGP_LOCAL_FAMILY;$_BGP_PEER_FAMILY;$_BGP_LOCAL_AS;$_BGP_PEER_AS;$_BGP_PEER_CLUSTER;$_BGP_PEER_GROUP" >> data/bgp_neis.dat
    fi
  done
  let _i_cmd+=1
	
  #_C[15]="show router mpls path"
  # PATHs CONFIGURATION
  # echo "$_IP_NODE:PATH" >> errors.log
  _PI_PATH=$(($(cat -n $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Path Name" | head -1 | awk '{print $1}' | tr -d "\t" | col -bx | sed 's/ //g')+2))
  _PF_PATH=$(($(cat -n $_TF | tail -$(($_PT-$_PI_PATH+1)) | head -$((${_P[$(($_i_cmd+1))]}-$_PI_PATH+1)) | grep "\-\-\-\-" | tail -1 | awk '{print $1}' | tr -d "\t" | col -bx | sed 's/ //g')-1))
  if (( $_PF_PATH > 0 )); then
    _n_path=$(cat $_TF | tail -$(($_PT-$_PI_PATH+1)) | head -$(($_PF_PATH-$_PI_PATH+1)) | grep . | cut -c1-32 | sed 's/ //g' | tr -d "\t" | col -bx | grep . | wc -l)
	i=1
	for (( _i_path=1; _i_path<=$_n_path; _i_path++ )); do
	  _PATH_NAME=$(cat $_TF | tail -$(($_PT-$_PI_PATH+1)) | head -$(($_PF_PATH-$_PI_PATH+1)) | head -$i | tail -1 | cut -c1-32 | tr -d "\r" | col -bx)
	  _PATH_STATE=$(cat $_TF | tail -$(($_PT-$_PI_PATH+1)) | head -$(($_PF_PATH-$_PI_PATH+1)) | head -$i | tail -1 | cut -c34-37 | sed 's/ //g' | tr -d "\r" | col -bx)
	  while [ 1 ]; do
		_PATH_HOP=$(cat $_TF | tail -$(($_PT-$_PI_PATH+1)) | head -$(($_PF_PATH-$_PI_PATH+1)) | head -$i | tail -1 | cut -c39-49 | sed 's/ //g' | tr -d "\r" | col -bx)
		_PATH_HOP_IP=$(cat $_TF | tail -$(($_PT-$_PI_PATH+1)) | head -$(($_PF_PATH-$_PI_PATH+1)) | head -$i | tail -1 | cut -c51-66 | sed 's/ //g' | tr -d "\r" | col -bx)
		_PATH_HOP_TYPE=$(cat $_TF | tail -$(($_PT-$_PI_PATH+1)) | head -$(($_PF_PATH-$_PI_PATH+1)) | head -$i | tail -1 | cut -c68-74 | sed 's/ //g' | tr -d "\r" | col -bx)
		let i+=1
		if (( $(echo $_PATH_HOP | sed 's/ //g' | tr -d "\t" | col -bx | grep . | wc -l) < 1 )); then
		  break 
		else
		  if (( $(cat "data/paths.dat" 2> /dev/null | grep "$_IP_NODE;$_PATH_NAME;$_PATH_HOP" | wc -l) < 1 )); then
			echo "$_IP_NODE;$_PATH_NAME;$_PATH_HOP;$_PATH_STATE;$_PATH_HOP_IP;$_PATH_HOP_TYPE" >> data/paths.dat
		  fi
		fi
	  done
	done
  fi
  let _i_cmd+=1

  #_C[16]="show router mpls lsp detail"
  # LSPs CONFIGURATION
  # echo "$_IP_NODE:LSP" >> errors.log
  _n_lsp=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "LSP Name" | wc -l)
  for (( _i_lsp=1; _i_lsp<=$_n_lsp; _i_lsp++ )); do
	_PI_LSP=$(cat -n $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "LSP Name" | head -$_i_lsp | tail -1 | awk '{print $1}' | tr -d "\t" | col -bx | sed 's/ //g')
	if (( $_i_lsp < $_n_lsp )); then
	  _PF_LSP=$(($(cat -n $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "LSP Name" | head -$(($_i_lsp+1)) | tail -1 | awk '{print $1}' | tr -d "\t" | col -bx | sed 's/ //g')-1))
	  _PF2_LSP=$(($(cat -n $_TF | tail -$(($_PT-${_P[$_i_cmd+1]}+1)) | head -$((${_P[$(($_i_cmd+2))]}-${_P[$_i_cmd+1]})) | grep "LSP Name" | head -$(($_i_lsp+1)) | tail -1 | awk '{print $1}' | tr -d "\t" | col -bx | sed 's/ //g')-1))
	else 
	  _PF_LSP=$((${_P[$_i_cmd+1]}-1))
	  _PF2_LSP=$((${_P[$_i_cmd+2]}-1))							
	fi
	_LSP_NAME=$(cat $_TF | tail -$(($_PT-$_PI_LSP+1)) | head -$(($_PF_LSP-$_PI_LSP+1)) | grep "LSP Name" | tr ":" "\n" | head -2 | tail -1  | cut -c2-33 | tr -d "\r" | col -bx)
	_LSP_TO=$(cat $_TF | tail -$(($_PT-$_PF_LSP+1)) | head -$(($_PF2_LSP-$_PF_LSP+1)) | grep "To" | tr ":" "\n" | tail -1 | sed 's/ //g' | tr -d "\r" | col -bx)
	_LSP_CSPF=$(cat $_TF | tail -$(($_PT-$_PI_LSP+1)) | head -$(($_PF_LSP-$_PI_LSP+1)) | grep "CSPF" | grep -v "Grp"| awk '{print $3}' | tr -d "\r" | col -bx)
	if (( $(echo $_LSP_CSPF | grep "Enabled" | wc -l) > 0 )); then 
	  _LSP_TE_METRIC=$(cat $_TF | tail -$(($_PT-$_PI_LSP+1)) | head -$(($_PF_LSP-$_PI_LSP+1)) | grep "Use TE metric" | awk '{print $8}' | tr -d "\r" | col -bx)
	else
	  _LSP_TE_METRIC="N/A"
	fi
	_LSP_FRR=$(cat $_TF | tail -$(($_PT-$_PI_LSP+1)) | head -$(($_PF_LSP-$_PI_LSP+1)) | grep "FastReroute" | awk '{print $3}' | tr -d "\r" | col -bx)
	if (( $(echo $_LSP_FRR | grep "Enabled" | wc -l) > 0 )); then 
	  _LSP_FRR_METHOD=$(cat $_TF | tail -$(($_PT-$_PI_LSP+1)) | head -$(($_PF_LSP-$_PI_LSP+1)) | grep "FR Method" | awk '{print $4}' | tr -d "\r" | col -bx)
	else
	  _LSP_FRR_METHOD="N/A"
	fi
	_LSP_MTU=$(cat $_TF | tail -$(($_PT-$_PI_LSP+1)) | head -$(($_PF_LSP-$_PI_LSP+1)) | grep "MTU" | awk '{print $8}' | tr -d "\r" | col -bx)
	_LSP_PRIMARY=$(cat $_TF | tail -$(($_PT-$_PI_LSP+1)) | head -$(($_PF_LSP-$_PI_LSP+1)) | grep "Primary" | tr ":" "\n" | head -2 | tail -1  | cut -c2-33 | tr -d "\r" | col -bx)
	_LSP_PRIMARY_S=$(cat $_TF | tail -$(($_PT-$_PI_LSP+1)) | head -$(($_PF_LSP-$_PI_LSP+1)) | grep "Primary" | tr ":" "\n" | head -2 | tail -1  | cut -c35-43 | tr " " "\n" | head -1 | tr -d "\r" | col -bx)
	if (( $(cat $_TF | tail -$(($_PT-$_PI_LSP+1)) | head -$(($_PF_LSP-$_PI_LSP+1)) | grep "Secondary" | wc -l) > 0 )); then 
	  _LSP_SECONDARY=$(cat $_TF | tail -$(($_PT-$_PI_LSP+1)) | head -$(($_PF_LSP-$_PI_LSP+1)) | grep "Secondary" | tr ":" "\n" | head -2 | tail -1  | cut -c2-33 | tr -d "\r" | col -bx)
	  _LSP_SECONDARY_S=$(cat $_TF | tail -$(($_PT-$_PI_LSP+1)) | head -$(($_PF_LSP-$_PI_LSP+1)) | grep "Secondary" | tr ":" "\n" | head -2 | tail -1  | cut -c35-43 | tr " " "\n" | head -1 | tr -d "\r" | col -bx)
	else 
	  _LSP_SECONDARY=""
	  _LSP_SECONDARY_S=""
	fi
	_LSP_ADM_S=$(cat $_TF | tail -$(($_PT-$_PI_LSP+1)) | head -$(($_PF_LSP-$_PI_LSP+1)) | grep "Adm State" | awk '{print $4}' | tr -d "\r" | col -bx)
	_LSP_OPE_S=$(cat $_TF | tail -$(($_PT-$_PI_LSP+1)) | head -$(($_PF_LSP-$_PI_LSP+1)) | grep "Oper State" | awk '{print $8}' | tr -d "\r" | col -bx)
	if (( $(cat "data/lsps.dat" 2> /dev/null | grep "$_IP_NODE;$_LSP_NAME;$_LSP_TO" | wc -l) < 1 )); then
	  echo "$_IP_NODE;$_LSP_NAME;$_LSP_TO;$_LSP_CSPF;$_LSP_TE_METRIC;$_LSP_FRR;$_LSP_FRR_METHOD;$_LSP_MTU;$_LSP_PRIMARY;$_LSP_PRIMARY_S;$_LSP_SECONDARY;$_LSP_SECONDARY_S;$_LSP_ADM_S;$_LSP_OPE_S" >> data/lsps.dat
	fi
  done
  let _i_cmd+=2
  
  #_C[17]="show router mpls lsp path detail"
  #_C[18]="show service sdp detail"
  # SDP LIST
  # echo "$_IP_NODE:SDP" >> errors.log
  _n_sdp=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "SDP Id" | wc -l)
  for (( _i_sdp=1; _i_sdp<=$_n_sdp; _i_sdp++ )); do
	_PI_SDP=$(cat -n $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "SDP Id" | head -$_i_sdp | tail -1 | awk '{print $1}' | tr -d "\t" | col -bx | sed 's/ //g')
	if (( $_i_sdp < $_n_sdp )); then
	  _PF_SDP=$(($(cat -n $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "SDP Id" | head -$(($_i_sdp+1)) | tail -1 | awk '{print $1}' | tr -d "\t" | col -bx | sed 's/ //g')-1))
	else
	  _PF_SDP=$((${_P[$_i_cmd+1]}-1))
	fi
	_SDP_ID=$(cat $_TF | tail -$(($_PT-$_PI_SDP+1)) | head -$(($_PF_SDP-$_PI_SDP+1)) | grep "SDP Id" | head -1 | awk '{print $4}' | tr -d "\r" | col -bx | sed 's/ //g')
	_SDP_ADM_MTU=$(cat $_TF | tail -$(($_PT-$_PI_SDP+1)) | head -$(($_PF_SDP-$_PI_SDP+1)) | grep "Admin Path MTU"  | head -1	| awk '{print $5}' | tr -d "\r" | col -bx | sed 's/ //g')
	_SDP_OPE_MTU=$(cat $_TF | tail -$(($_PT-$_PI_SDP+1)) | head -$(($_PF_SDP-$_PI_SDP+1)) | grep "Oper Path MTU" | head -1 | awk '{print $10}' | tr -d "\r" | col -bx | sed 's/ //g')
	_FAR_END=$(cat $_TF  | tail -$(($_PT-$_PI_SDP+1)) | head -$(($_PF_SDP-$_PI_SDP+1)) | grep "Far End" | head -1 | awk '{print $4}' | tr -d "\r" | col -bx | sed 's/ //g')
	_SDP_TYPE=$(cat $_TF | tail -$(($_PT-$_PI_SDP+1)) | head -$(($_PF_SDP-$_PI_SDP+1)) | grep "Delivery" | head -1 | awk '{print $7}' | tr -d "\r" | col -bx | sed 's/ //g')
	if (( $(echo $_SDP_TYPE | grep MPLS | wc -l) > 0 )); then
	  _SDP_LSP=$(cat $_TF | tail -$(($_PT-$_PI_SDP+1)) | head -$(($_PF_SDP-$_PI_SDP+1)) | grep "Lsp Name" | head -1 | head -1 | tr ":" "\n" | tail -1 | cut -c2-21 | tr -d "*" | tr -d "\r" | col -bx)
	  _SDP_LSP=$(cat "data/lsps.dat" | grep "$_IP_NODE;" | grep ";$_FAR_END;" | grep ";$_SDP_LSP" | head -1 | tr ";" "\n" | head -2 | tail -1)
	else _SDP_LSP="N/A"; fi
	_SDP_ADM_S=$(cat $_TF | tail -$(($_PT-$_PI_SDP+1)) | head -$(($_PF_SDP-$_PI_SDP+1)) | grep "Admin State" | head -1 | awk '{print $4}' | tr -d "\r" | col -bx | sed 's/ //g')
	_SDP_OPE_S=$(cat $_TF | tail -$(($_PT-$_PI_SDP+1)) | head -$(($_PF_SDP-$_PI_SDP+1)) | grep "Oper State" | head -1 | awk '{print $8}' | tr -d "\r" | col -bx | sed 's/ //g')
	if (( $(cat "data/sdps.dat" 2> /dev/null | grep "$_IP_NODE;$_SDP_ID;$_FAR_END" | wc -l) < 1 )); then
	  echo "$_IP_NODE;$_SDP_ID;$_FAR_END;$_SDP_ADM_MTU;$_SDP_OPE_MTU;$_SDP_TYPE;$_SDP_LSP;$_SDP_ADM_S;$_SDP_OPE_S" >> data/sdps.dat
	fi
  done
  let _i_cmd+=1
  
  #_C[19]="show service service-using"
  # SERVICE LIST
  # echo "$_IP_NODE:SVC" >> errors.log
  _PI_SVC=$(($(cat -n $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "ServiceId" | head -1 | awk '{print $1}' | tr -d "\t" | col -bx | sed 's/ //g')+2))
  _PF_SVC=$(($(cat -n $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Matching" | tail -1 | awk '{print $1}' | tr -d "\t" | col -bx | sed 's/ //g')-2))
  _n_svc=$(($_PF_SVC-$_PI_SVC+1))
  if (( $_n_svc < 0 )); then _n_svc=0; fi
  for (( _i_svc=1; _i_svc<=$_n_svc; _i_svc++ )); do
    _SVC_ID=$(cat $_TF | tail -$(($_PT-$_PI_SVC+1)) | head -$(($_PF_SVC-$_PI_SVC+1)) | head -$_i_svc | tail -1 | awk '{print $1}' | tr -d "\r" | col -bx | sed 's/ //g')
	_SVC_TYPE=$(cat $_TF | tail -$(($_PT-$_PI_SVC+1)) | head -$(($_PF_SVC-$_PI_SVC+1)) | head -$_i_svc | tail -1 | awk '{print $2}' | tr -d "\r" | col -bx | sed 's/ //g')
	_SVC_ADM_S=$(cat $_TF | tail -$(($_PT-$_PI_SVC+1)) | head -$(($_PF_SVC-$_PI_SVC+1)) | head -$_i_svc | tail -1 | awk '{print $3}' | tr -d "\r" | col -bx | sed 's/ //g')
	_SVC_OPE_S=$(cat $_TF | tail -$(($_PT-$_PI_SVC+1)) | head -$(($_PF_SVC-$_PI_SVC+1)) | head -$_i_svc | tail -1 | awk '{print $4}' | tr -d "\r" | col -bx | sed 's/ //g')
	_SVC_CUSTOMER=$(cat $_TF | tail -$(($_PT-$_PI_SVC+1)) | head -$(($_PF_SVC-$_PI_SVC+1)) | head -$_i_svc | tail -1 | awk '{print $5}' | tr -d "\r" | col -bx | sed 's/ //g')
	_SVC_NAME=$(cat $_TF | tail -$(($_PT-$_PI_SVC+1)) | head -$(($_PF_SVC-$_PI_SVC+1)) | head -$_i_svc | tail -1 | awk '{print $6}' | tr -d "\r" | col -bx | sed 's/ //g')
	
	if (( $(cat "data/svcs.dat" 2> /dev/null | grep "$_IP_NODE;$_SVC_ID;$_SVC_TYPE" | wc -l) < 1 )); then
	  echo "$_IP_NODE;$_SVC_ID;$_SVC_TYPE;$_SVC_ADM_S;$_SVC_OPE_S;$_SVC_CUSTOMER;$_SVC_NAME" >> data/svcs.dat
	fi
  done
  let _i_cmd+=1

  #_C[20]="show service sap-using"
  # SVC SAP LIST
  # echo "$_IP_NODE:SVC SAP" >> errors.log
  _PI_SAP=$(($(cat -n $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "PortId" | head -1 | awk '{print $1}' | tr -d "\t" | col -bx | sed 's/ //g')+3))
  _PF_SAP=$(($(cat -n $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Number" | tail -1 | awk '{print $1}' | tr -d "\t" | col -bx | sed 's/ //g')-2))
  _n_ssap=$(($_PF_SAP-$_PI_SAP+1))
  if (( $_n_ssap > 0 )); then
    for (( _i_ssap=1; _i_ssap<=$_n_ssap; _i_ssap++ )); do
	  _SAP_ID=$(cat $_TF | tail -$(($_PT-$_PI_SAP+1)) | head -$(($_PF_SAP-$_PI_SAP+1)) | head -$_i_ssap | tail -1 | awk '{print $1}' | tr -d "\r" | col -bx | sed 's/ //g')
	  _SVC_ID=$(cat $_TF | tail -$(($_PT-$_PI_SAP+1)) | head -$(($_PF_SAP-$_PI_SAP+1)) | head -$_i_ssap | tail -1 | awk '{print $2}' | tr -d "\r" | col -bx | sed 's/ //g')
	  _SAP_ADM_S=$(cat $_TF | tail -$(($_PT-$_PI_SAP+1)) | head -$(($_PF_SAP-$_PI_SAP+1)) | head -$_i_ssap | tail -1 | awk '{print $7}' | tr -d "\r" | col -bx | sed 's/ //g')
	  _SAP_OPE_S=$(cat $_TF | tail -$(($_PT-$_PI_SAP+1)) | head -$(($_PF_SAP-$_PI_SAP+1)) | head -$_i_ssap | tail -1 | awk '{print $8}' | tr -d "\r" | col -bx | sed 's/ //g')
	  if (( $(echo $_SAP_ID | grep ":" | wc -l) > 0 )); then
	    _PORT_VID=$(echo $_SAP_ID | tr ":" "\n" | tail -1 | tr -d "\r" | col -bx)
	  else
	    _PORT_VID="N/A"
	  fi
	  _PORT_ID=$(echo $_SAP_ID | tr ":" "\n" | head -1 | tr -d "\r" | col -bx)
	
	  if (( $(cat "data/svc_saps.dat" 2> /dev/null | grep "$_IP_NODE;$_PORT_ID;$_PORT_VID;$_SVC_ID" | wc -l) < 1 )); then
	    echo "$_IP_NODE;$_PORT_ID;$_PORT_VID;$_SVC_ID;$_SAP_ADM_S;$_SAP_OPE_S" >> data/svc_saps.dat
	  fi
    done
  fi
  let _i_cmd+=1

  #_C[21]="show service sdp-using"
  # SVC SDP LIST
  # echo "$_IP_NODE:SVC SDP" >> errors.log
  _PI_SSDP=$(($(cat -n $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "SvcId" | head -1 | awk '{print $1}' | tr -d "\t" | col -bx | sed 's/ //g')+2))
  _PF_SSDP=$(($(cat -n $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Number" | tail -1 | awk '{print $1}' | tr -d "\t" | col -bx | sed 's/ //g')-2))
  _n_ssdp=$(($_PF_SSDP-$_PI_SSDP+1))
  if (( $_n_ssdp < 0 )); then _n_ssdp=0; fi
  for (( _i_ssdp=1; _i_ssdp<=$_n_ssdp; _i_ssdp++ )); do
	_SDP_ID=$(cat $_TF | tail -$(($_PT-$_PI_SSDP+1)) | head -$(($_PF_SSDP-$_PI_SSDP+1)) | head -$_i_ssdp | tail -1 | awk '{print $2}' | tr ":" "\n" | head -1 | tr -d "\r" | col -bx | sed 's/ //g')
	_SDP_VID=$(cat $_TF | tail -$(($_PT-$_PI_SSDP+1)) | head -$(($_PF_SSDP-$_PI_SSDP+1)) | head -$_i_ssdp | tail -1 | awk '{print $2}' | tr ":" "\n" | head -2 | tail -1 | tr -d "\r" | col -bx | sed 's/ //g')
	_SVC_ID=$(cat $_TF | tail -$(($_PT-$_PI_SSDP+1)) | head -$(($_PF_SSDP-$_PI_SSDP+1)) | head -$_i_ssdp | tail -1 | awk '{print $1}' | tr -d "\r" | col -bx | sed 's/ //g')
	_SDP_TYPE=$(cat $_TF | tail -$(($_PT-$_PI_SSDP+1)) | head -$(($_PF_SSDP-$_PI_SSDP+1)) | head -$_i_ssdp | tail -1 | awk '{print $3}' | tr -d "\r" | col -bx | sed 's/ //g')
	_SDP_OPE_S=$(cat $_TF | tail -$(($_PT-$_PI_SSDP+1)) | head -$(($_PF_SSDP-$_PI_SSDP+1)) | head -$_i_ssdp | tail -1 | awk '{print $5}' | tr -d "\r" | col -bx | sed 's/ //g')
	if (( $(echo $_SVC_ID | grep "\-\-\-" | wc -l) < 1 )); then
	  if (( $(cat "data/svc_sdps.dat" 2> /dev/null | grep "$_IP_NODE;$_SDP_ID;$_SVC_ID" | wc -l) < 1 )); then
	    echo "$_IP_NODE;$_SDP_ID;$_SDP_VID;$_SVC_ID;$_SDP_TYPE;$_SDP_OPE_S" >> data/svc_sdps.dat
	  fi
	fi
  done
  let _i_cmd+=1
  
  #_C[22]="show service fdb-mac"
  # SVC FDB
  # echo "$_IP_NODE:SVC FDB" >> errors.log
  if (( $(cat "data/svcs.dat" | grep "$_IP_NODE;" | grep VPLS | wc -l) > 0 )); then
    _n_sfdb=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "L/" | wc -l)
    for (( _i_sfdb=1; _i_sfdb<=$_n_sfdb; _i_sfdb++ )); do
	  _SVC_ID=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "L/" | head -$_i_sfdb | tail -1 | awk '{print $1}' | tr -d "\r" | col -bx | sed 's/ //g')
	  _MAC_HOST=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "L/" | head -$_i_sfdb | tail -1 | awk '{print $2}' | tr -d "\r" | col -bx | sed 's/ //g')
	  _SXP_TYPE=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "L/" | head -$_i_sfdb | tail -1 | awk '{print $3}' | tr ":" "\n" | head -1 | tr -d "\r" | col -bx | sed 's/ //g')
	  _SXP_VALUE=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "L/" | head -$_i_sfdb | tail -1 | awk '{print $3}' | tr ":" "\n" | head -2 | tail -1 | tr -d "\r" | col -bx | sed 's/ //g')
	  _SXP_VID=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "L/" | head -$_i_sfdb | tail -1 | awk '{print $3}' | tr ":" "\n" | head -3 | tail -1 | tr -d "\r" | col -bx | sed 's/ //g')
	  
	  if (( $(cat "data/svc_fdbs.dat" 2> /dev/null | grep "$_IP_NODE;$_SVC_ID;$_MAC_HOST" | wc -l) < 1 )); then
		echo "$_IP_NODE;$_SVC_ID;$_MAC_HOST;$_SXP_TYPE;$_SXP_VALUE;$_SXP_VID" >> data/svc_fdbs.dat
	  fi
	done
  fi
  let _i_cmd+=1
  
  #_C[23]="show multilink-bundle detail"
  # BUNDLE GROUPS
  # echo "$_IP_NODE:BUNDLE" >> errors.log
  _n_bundle=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Bundle Id" | wc -l)
  _BMT=1
  for (( _i_bundle=1; _i_bundle<=$_n_bundle; _i_bundle++ )); do
	_PI_BUNDLE=$(cat -n $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Bundle bundle-" | head -$_i_bundle | tail -1 | awk '{print $1}' | tr -d "\t" | col -bx | sed 's/ //g')
	if (( $_i_bundle < $_n_bundle )); then
	  _PF_BUNDLE=$(($(cat -n $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Bundle bundle-" | head -$(($_i_bundle+1)) | tail -1 | awk '{print $1}' | tr -d "\t" | col -bx | sed 's/ //g')-1))
	else
	  _PF_BUNDLE=$((${_P[$_i_cmd+1]}-1))
	fi
	_BUNDLE_ID=$(cat $_TF | tail -$(($_PT-$_PI_BUNDLE+1)) | head -$(($_PF_BUNDLE-$_PI_BUNDLE+1)) | grep "Bundle Id" | head -1 | awk '{print $4}' | tr -d "\r" | col -bx | sed 's/ //g')
	_BUNLDE_DESC=$(cat $_TF | tail -$(($_PT-$_PI_BUNDLE+1)) | head -$(($_PF_BUNDLE-$_PI_BUNDLE+1)) | grep "Description" | head -1 | tr ":" "\n" | tail -1 | tr -d "\r" | col -bx | sed 's/ //g')
	_BUNDLE_TYPE=$(cat $_TF | tail -$(($_PT-$_PI_BUNDLE+1)) | head -$(($_PF_BUNDLE-$_PI_BUNDLE+1)) | grep "Type" | head -1 | awk '{print $7}' | tr -d "\r" | col -bx | sed 's/ //g')
	_BUNDLE_ADM_STATE=$(cat $_TF | tail -$(($_PT-$_PI_BUNDLE+1)) | head -$(($_PF_BUNDLE-$_PI_BUNDLE+1)) | grep "Admin Status" | head -1 | awk '{print $4}' | tr -d "\r" | col -bx | sed 's/ //g')
	_BUNDLE_OPE_STATE=$(cat $_TF | tail -$(($_PT-$_PI_BUNDLE+1)) | head -$(($_PF_BUNDLE-$_PI_BUNDLE+1)) | grep "Oper Status" | head -1 | awk '{print $8}' | tr -d "\r" | col -bx | sed 's/ //g')
	_BUNDLE_TOT_MEMBERS=$(cat $_TF | tail -$(($_PT-$_PI_BUNDLE+1)) | head -$(($_PF_BUNDLE-$_PI_BUNDLE+1)) | grep "Total Links" | head -1 | awk '{print $4}' | tr -d "\r" | col -bx | sed 's/ //g')
	_BUNDLE_ACT_MEMBERS=$(cat $_TF | tail -$(($_PT-$_PI_BUNDLE+1)) | head -$(($_PF_BUNDLE-$_PI_BUNDLE+1)) | grep "Active Links" | head -1 | awk '{print $8}' | tr -d "\r" | col -bx | sed 's/ //g')
	_BUNDLE_BANDWIDTH=$(cat $_TF | tail -$(($_PT-$_PI_BUNDLE+1)) | head -$(($_PF_BUNDLE-$_PI_BUNDLE+1)) | grep "Bandwidth" | head -1 | tr ":" "\n" | tail -1 | tr -d "\r" | col -bx | sed 's/ //g')
	_BUNDLE_MODE=$(cat $_TF | tail -$(($_PT-$_PI_BUNDLE+1)) | head -$(($_PF_BUNDLE-$_PI_BUNDLE+1)) | grep "Mode" | head -1 | awk '{print $3}' | tr -d "\r" | col -bx | sed 's/ //g')
	_BUNDLE_MEMBERS=""
	for (( _i_bundle_m=1; _i_bundle_m<=$_BUNDLE_TOT_MEMBERS; _i_bundle_m++ )); do
	  _BUNDLE_MEMBERS="$_BUNDLE_MEMBERS$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep ".\/.\/." | grep -v "Member" | head -$_BMT | tail -1 | awk '{print $1}' | tr -d "\r" | col -bx | sed 's/ //g')"
	  if (( $_i_bundle_m < $_BUNDLE_TOT_MEMBERS )); then _BUNDLE_MEMBERS="$_BUNDLE_MEMBERS "; fi
	  let _i_bundle_m+=1
	  let _BMT+=1
	done
	
	if (( $(cat "data/bundles.dat" 2> /dev/null | grep "$_IP_NODE;$_BUNLDE_ID;$_BUNDLE_MODE" | wc -l) < 1 )); then
	  echo "$_IP_NODE;$_BUNDLE_ID;$_BUNDLE_MODE;$_BUNDLE_TYPE;$_BUNDLE_TOT_MEMBERS;$_BUNDLE_ACT_MEMBERS;$_BUNDLE_BANDWIDTH;$_BUNDLE_ADM_STATE;$_BUNDLE_OPE_STATE;$_BUNDLE_MEMBERS;$_BUNLDE_DESC" >> data/bundles.dat
	fi
  done
  let _i_cmd+=1

  #_C[24]="show aps detail"
  # APS GROUPS
  # echo "$_IP_NODE:APS" >> errors.log
  _n_aps=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Group Id" | wc -l)
  for (( _i_aps=1; _i_aps<=$_n_aps; _i_aps++ )); do
	_PI_APS=$(cat -n $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "APS Group:" | head -$_i_aps | tail -1 | awk '{print $1}' | tr -d "\t" | col -bx | sed 's/ //g')
	if (( $_i_aps < $_n_aps )); then
	  _PF_APS=$(($(cat -n $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "APS Group:" | head -$(($_i_aps+1)) | tail -1 | awk '{print $1}' | tr -d "\t" | col -bx | sed 's/ //g')-1))
	else
	  _PF_APS=$((${_P[$(($_i_cmd+1))]}-1))
	fi
	_APS_ID="aps-$(cat $_TF | tail -$(($_PT-$_PI_APS+1)) | head -$(($_PF_APS-$_PI_APS+1)) | grep "Group Id" | head -1 | awk '{print $4}' | tr -d "\r" | col -bx | sed 's/ //g')"
	_APS_DESC=$(cat $_TF | tail -$(($_PT-$_PI_APS+1)) | head -$(($_PF_APS-$_PI_APS+1)) | grep "Description" | head -1 | tr ":" "\n" | tail -1 | tr -d "\r" | col -bx | sed 's/ //g')
	_APS_ADM_STATE=$(cat $_TF | tail -$(($_PT-$_PI_APS+1)) | head -$(($_PF_APS-$_PI_APS+1)) | grep "Admin Status" | head -1 | awk '{print $4}' | tr -d "\r" | col -bx | sed 's/ //g')
	_APS_OPE_STATE=$(cat $_TF | tail -$(($_PT-$_PI_APS+1)) | head -$(($_PF_APS-$_PI_APS+1)) | grep "Oper Status" | head -1 | awk '{print $8}' | tr -d "\r" | col -bx | sed 's/ //g')
	_WORKING_PORT=$(cat $_TF | tail -$(($_PT-$_PI_APS+1)) | head -$(($_PF_APS-$_PI_APS+1)) | grep "Working Circuit" | head -1 | awk '{print $4}' | tr -d "\r" | col -bx | sed 's/ //g')
	_PROTECT_PORT=$(cat $_TF | tail -$(($_PT-$_PI_APS+1)) | head -$(($_PF_APS-$_PI_APS+1)) | grep "Protection Circuit" | head -1 | awk '{print $8}' | tr -d "\r" | col -bx | sed 's/ //g')
	_ACTIVE_PORT=$(cat $_TF | tail -$(($_PT-$_PI_APS+1)) | head -$(($_PF_APS-$_PI_APS+1)) | grep "Active Circuit" | head -1 | awk '{print $8}' | tr -d "\r" | col -bx | sed 's/ //g')
	_APS_NEIGHBOR=$(cat $_TF | tail -$(($_PT-$_PI_APS+1)) | head -$(($_PF_APS-$_PI_APS+1)) | grep "Neighbor" | head -1 | awk '{print $3}' | tr -d "\r" | col -bx | sed 's/ //g')
	_APS_MODE=$(cat $_TF | tail -$(($_PT-$_PI_APS+1)) | head -$(($_PF_APS-$_PI_APS+1)) | grep "Revertive-mode" | head -1 | awk '{print $3}' | tr -d "\r" | col -bx | sed 's/ //g')
	_APS_REVERT_TIME=$(cat $_TF | tail -$(($_PT-$_PI_APS+1)) | head -$(($_PF_APS-$_PI_APS+1)) | grep "Revert-time" | head -1 | awk '{print $7}' | tr -d "\r" | col -bx | sed 's/ //g')
	
	if (( $(cat "data/apss.dat" 2> /dev/null | grep "$_IP_NODE;$_APS_ID;$_WORKING_PORT;$_PROTECT_PORT" | wc -l) < 1 )); then
	  echo "$_IP_NODE;$_APS_ID;$_WORKING_PORT;$_PROTECT_PORT;$_ACTIVE_PORT;$_APS_MODE;$_APS_REVERT_TIME;$_APS_NEIGHBOR;$_APS_ADM_STATE;$_APS_OPE_STATE;$_APS_DESC" >> data/apss.dat
	fi
  done
  let _i_cmd+=1

  #_C[25]="show lag detail"
  # LAG GROUPS
  # echo "$_IP_NODE:LAG" >> errors.log
  _n_lag=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Lag-id" | wc -l)
  _LMT=1
  for (( _i_lag=1; _i_lag<=$_n_lag; _i_lag++ )); do
	_PI_LAG=$(cat -n $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Description" | head -$_i_lag | tail -1 | awk '{print $1}' | tr -d "\t" | col -bx | sed 's/ //g')
	if (( $_i_lag < $_n_lag )); then
	  _PF_LAG=$(cat -n $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Description" | head -$(($_i_lag+1)) | tail -1 | awk '{print $1}' | tr -d "\t" | col -bx | sed 's/ //g')
	else
	  _PF_LAG=$(cat -n $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | tail -1 | awk '{print $1}' | tr -d "\t" | col -bx | sed 's/ //g')
	fi
	_LAGM_COUNT=$(cat $_TF | tail -$(($_PT-$_PI_LAG+1)) | head -$(($_PF_LAG-$_PI_LAG+1)) | grep ".\/.\/." | grep -v actor | grep -v partner | wc -l | col -bx | sed 's/ //g')
	_LAG_ID="lag-$(cat $_TF | tail -$(($_PT-$_PI_LAG+1)) | head -$(($_PF_LAG-$_PI_LAG+1)) | grep "Lag-id" | head -1 | tail -1 | awk '{print $3}' | tr -d "\r" | col -bx | sed 's/ //g')"
	_LAG_DESC=$(cat $_TF | tail -$(($_PT-$_PI_LAG+1)) | head -$(($_PF_LAG-$_PI_LAG+1)) | grep "Description" | head -1 | tail -1 | tr ":" "\n" | tail -1 | tr -d "\r" | col -bx | sed 's/ //g')
	_LAG_MODE=$(cat $_TF | tail -$(($_PT-$_PI_LAG+1)) | head -$(($_PF_LAG-$_PI_LAG+1)) | grep "Mode" | head -1 | tail -1 | awk '{print $6}' | tr -d "\r" | col -bx | sed 's/ //g')
	_LAG_ENCAP=$(cat $_TF | tail -$(($_PT-$_PI_LAG+1)) | head -$(($_PF_LAG-$_PI_LAG+1)) | grep "Encap Type" | head -1 | tail -1 | awk '{print $8}' | tr -d "\r" | col -bx | sed 's/ //g')
	_LAG_ADM_STATE=$(cat $_TF | tail -$(($_PT-$_PI_LAG+1)) | head -$(($_PF_LAG-$_PI_LAG+1)) | grep "Adm" | grep -v "Stdby" | head -1 | tail -1 | awk '{print $3}' | tr -d "\r" | col -bx | sed 's/ //g')
	_LAG_OPE_STATE=$(cat $_TF | tail -$(($_PT-$_PI_LAG+1)) | head -$(($_PF_LAG-$_PI_LAG+1)) | grep "Adm" | grep -v "Stdby" | head -1 | tail -1 | awk '{print $6}' | tr -d "\r" | col -bx | sed 's/ //g')
	_LAG_LACP=$(cat $_TF | tail -$(($_PT-$_PI_LAG+1)) | head -$(($_PF_LAG-$_PI_LAG+1)) | grep "LACP" | head -1 | tail -1 | awk '{print $3}' | tr -d "\r" | col -bx | sed 's/ //g')
	_LAG_MEMBERS=""
	for (( _i_lag_m=1; _i_lag_m<=$_LAGM_COUNT; _i_lag_m++ )); do
	  _LAG_MEMBERS="$_LAG_MEMBERS$(cat $_TF | tail -$(($_PT-$_PI_LAG+1)) | head -$(($_PF_LAG-$_PI_LAG+1)) | grep ".\/.\/." | grep -v actor | grep -v partner | head -$_LMT | tail -1 | awk '{print $1}' | tr -d "\r" | col -bx | sed 's/ //g')"
      if (( $_i_lag_m < $_LAGM_COUNT )); then _LAG_MEMBERS="$_LAG_MEMBERS "; fi
	  let _LMT+=1
	done
	if (( $(cat "data/lags.dat" 2> /dev/null | grep "$_IP_NODE;$_BUNLDE_ID;$_BUNDLE_MODE" | wc -l) < 1 )); then
      echo "$_IP_NODE;$_LAG_ID;$_LAG_MODE;$_LAG_ENCAP;$_LAGM_COUNT;$_LAG_LACP;$_LAG_ADM_STATE;$_LAG_OPE_STATE;$_LAG_MEMBERS;$_LAG_DESC" >> data/lags.dat
	fi
  done
  let _i_cmd+=1

  #_C[26]="show port"
  # PORTS
  # echo "$_IP_NODE:PORT" >> errors.log
  _n_ports=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep ".\/.\/." | grep -v "\." | grep -v Link | wc -l | col -bx | sed 's/ //g')  
  for (( _i_ports=1; _i_ports<=$_n_ports; _i_ports++ )); do		
	_id_port=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep ".\/.\/." | grep -v "\." | grep -v Link | awk '{print $1}' | head -$_i_ports | tail -1 | tr -d "\r" | col -bx | sed 's/ //g')
	_adm_status_port=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep ".\/.\/." | grep -v "\." | grep -v Link | awk '{print $2}' | head -$_i_ports | tail -1 | tr -d "\r" | col -bx | sed 's/ //g')
	_link_status_port=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep ".\/.\/." | grep -v "\." | grep -v Link | awk '{print $3}' | head -$_i_ports | tail -1 | tr -d "\r" | col -bx | sed 's/ //g')
	_ope_status_port=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep ".\/.\/." | grep -v "\." | grep -v Link | awk '{print $4}' | head -$_i_ports | tail -1 | tr -d "\r" | col -bx | sed 's/ //g')
	_adm_mtu_port=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep ".\/.\/." | grep -v "\." | grep -v Link | awk '{print $5}' | head -$_i_ports | tail -1 | tr -d "\r" | col -bx | sed 's/ //g')
	_ope_mtu_port=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep ".\/.\/." | grep -v "\." | grep -v Link | awk '{print $6}' | head -$_i_ports | tail -1 | tr -d "\r" | col -bx | sed 's/ //g')
	_group_id=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep ".\/.\/." | grep -v "\." | grep -v Link | awk '{print $7}' | head -$_i_ports | tail -1 | tr -d "\r" | col -bx | sed 's/ //g')
	_mode_port=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep ".\/.\/." | grep -v "\." | grep -v Link | awk '{print $8}' | head -$_i_ports | tail -1 | tr -d "\r" | col -bx | sed 's/ //g')
	_encap_port=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep ".\/.\/." | grep -v "\." | grep -v Link | awk '{print $9}' | head -$_i_ports | tail -1 | tr -d "\r" | col -bx | sed 's/ //g')
	_type_port=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep ".\/.\/." | grep -v "\." | grep -v Link | awk '{print $10}' | head -$_i_ports | tail -1 | tr -d "\r" | col -bx | sed 's/ //g')
	_type_sfp=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep ".\/.\/." | grep -v "\." | grep -v Link | awk '{print $11 " " $12}' | head -$_i_ports | tail -1 | tr -d "\r" | col -bx | sed 's/ //g')
	
	if (( $(echo $_ope_mtu_port | wc -c) > 1 )); then 
	  if (( $(cat "data/ports.dat" 2> /dev/null | grep "$_IP_NODE;$_id_port;" | wc -l) < 1 )); then
	    echo "$_IP_NODE;$_id_port;$_adm_status_port;$_link_status_port;$_ope_status_port;$_adm_mtu_port;$_ope_mtu_port;$_group_id;$_mode_port;$_encap_port;$_type_port;$_type_sfp" >> data/ports.dat
	  fi
	fi
  done
  let _i_cmd+=1

  #_C[27]="show router ospf database | match LSA"
  # LSA
  # echo "$_IP_NODE:LSA" >> errors.log  
  _lsas=$(cat $_TF | grep "No. of LSAs:" | tr " " "\n" | tail -1)

	
    if (( $(cat "data/lsa.dat" 2> /dev/null | grep "$_IP_NODE;$_lsas;" | wc -l) < 1 )); then
      echo "$_IP_NODE;$_lsas" >> data/lsa.dat
    fi


  let _i_cmd+=1
  
  #_C[28]="show router mpls status"
  # RESIGNAL TIMER
  # echo "$_IP_NODE:RESIGNALTIMER" >> errors.log  
  _ResignalTimer=$( cat $_TF | grep "Resignal Timer     : " | tr ":" "\n" | tail -1 )
    
	if (( $(cat "data/ResignalTimer.dat" 2> /dev/null | grep "$_IP_NODE;$_ResignalTimer;" | wc -l) < 1 )); then
      echo "$_IP_NODE;$_ResignalTimer" >> data/ResignalTimer.dat
    fi
  let _i_cmd+=1   
  
  #_C[29]="admin display-config"
  # VPLS Horizon Group
i  # echo "$_IP_NODE:Horizon-Group" >> errors.log  
  #echo "$_NODE_NAME;$_IP_NODE;$_NODE_TYPE;$_VPLS_HorizonGroup;$_HorizonGroup;IP-RAN;HR-IP;VPLS;SPLIT-HORIZON" >> data/VPLS.dat
#  echo "$_NODE_TYPE == 7750SR-7" >> tipo_de_equipo.txt
#  if [ $_NODE_TYPE == "7750SR-7" ]; then
#	echo "$_NODE_TYPE == 7750SR-7" >> tipo_de_equipo-if.txt
#  fi

	_n_HorizonGroup=$( cat $_TF | grep "vpls" | grep "customer 1 create" | wc -l )
	for (( _i_HorizonGroup=1; _i_HorizonGroup<=$_n_HorizonGroup; _i_HorizonGroup++ )); do	
		_total_lines_HG=$( cat $_TF | wc -l)
		#_line_HorizonGroup_uno=$( cat -n $_TF | grep "vpls" | grep "customer 1 create" | head -$_i_HorizonGroup | tail -1 | tr " " "\n" | head -2 | tail -1 )		_line_HorizonGroup_uno=$( cat -n $_TF | grep "vpls" | grep "customer 1 create" | head -$_i_HorizonGroup | tail -1 | awk '{print $1}' )
		#_VPLS_HorizonGroup=$( cat -n $_TF | grep "vpls" | grep "customer 1 create" | head -$_i_HorizonGroup | tail -1 | tr " " "\n" | head -11 | tail -1 )
                _VPLS_HorizonGroup=$( cat -n $_TF | grep "vpls" | grep "customer 1 create" | head -$_i_HorizonGroup | tail -1 | awk '{print $3}' )

		if(($_i_HorizonGroup<$_n_HorizonGroup));then
			#_line_HorizonGroup_dos=$( cat -n $_TF | grep "vpls" | grep "customer 1 create" | head -$(($_i_HorizonGroup+1)) | tail -1 | tr " " "\n" | head -2 | tail -1 )
                        _line_HorizonGroup_dos=$( cat -n $_TF | grep "vpls" | grep "customer 1 create" | head -$(($_i_HorizonGroup+1)) | tail -1 | awk '{print $1}' )
		        #_HorizonGroup=$( cat -n $_TF | tail -$(($_total_lines_HG-$_line_HorizonGroup_uno+1)) | head -$(($_line_HorizonGroup_dos-$_line_HorizonGroup_uno)) | grep "split-horizon-group " | grep -v "spoke-sdp " | tr " " "0" | tr "0-9" "\n" | head -20 | tail -1 )
		        _HorizonGroup=$( cat -n $_TF | tail -$(($_total_lines_HG-$_line_HorizonGroup_uno+1)) | head -$(($_line_HorizonGroup_dos-$_line_HorizonGroup_uno)) | grep "split-horizon-group " | grep -v "spoke-sdp " | tr " " "0" | awk '{print $3}' )
                else
			#_Search=$( cat -n $_TF | grep "admin display" | grep "match" -v | tr "a-zA-Z " "\n" | head -2 | tail -1 )
			#_HorizonGroup=$( cat -n $_TF | tail -$(($_total_lines_HG-$_line_HorizonGroup_uno+1)) | grep "split-horizon-group " | grep -v "spoke-sdp " | tr " " "0" | tr "0-9" "\n" | head -20 | tail -1 )
		        _HorizonGroup=$( cat -n $_TF | tail -$(($_total_lines_HG-$_line_HorizonGroup_uno+1)) | grep "split-horizon-group " | grep -v "spoke-sdp " | awk '{print $3}' )
                fi
		echo "$_NODE_NAME;$_IP_NODE;$_NODE_TYPE;$_VPLS_HorizonGroup;$_HorizonGroup" >> data/VPLS.dat
	done
  #fi
  
  
  _CG=""
  _i_cmd=1
  # MONITOR PORTS
  _n_ports=$(cat data/ports.dat | grep "$_IP_NODE;" | grep ";Up;Yes;Up;" | wc -l | col -bx | sed 's/ //g')  
  for (( _i_ports=1; _i_ports<=$_n_ports; _i_ports++ )); do		
	_PORT_ID=$(cat data/ports.dat | grep "$_IP_NODE;" | grep ";Up;Yes;Up;" | head -$_i_ports | tail -1 | tr ";" "\n" | head -2 | tail -1)
	_CM="monitor port $_PORT_ID interval 3 rate repeat 1 | match capacity"
	_C[$_i_cmd]="monitor port $_PORT_ID interval 3 rate repeat 1 | match capacity"
	_CG=$(echo -e "$_CG\r$_CM")
	let _i_cmd+=1
  done

  # ENDPOINTS
  _n_svcs=$(cat data/svcs.dat | grep "$_IP_NODE;" | grep "pipe;Up;Up" | wc -l | col -bx | sed 's/ //g')  
  for (( _i_svcs=1; _i_svcs<=$_n_svcs; _i_svcs++ )); do		
	_SVC_ID=$(cat data/svcs.dat | grep "$_IP_NODE;" | grep "pipe;Up;Up" | head -$_i_svcs | tail -1 | tr ";" "\n" | head -2 | tail -1)
	_CS="show service id $_SVC_ID endpoint"
	_C[$_i_cmd]="show service id $_SVC_ID endpoint"
	_CG=$(echo -e "$_CG\r$_CS")
	let _i_cmd+=1
  done

  # VPRNS
  _n_svcs=$(cat data/svcs.dat | grep "$_IP_NODE;" | grep ";VPRN;Up;Up" | wc -l | col -bx | sed 's/ //g')  
  for (( _i_svcs=1; _i_svcs<=$_n_svcs; _i_svcs++ )); do		
	_SVC_ID=$(cat data/svcs.dat | grep "$_IP_NODE;" | grep ";VPRN;Up;Up" | head -$_i_svcs | tail -1 | tr ";" "\n" | head -2 | tail -1)
	_CI="show router $_SVC_ID interface detail"
	_CA="show router $_SVC_ID arp"
	_CV="show router $_SVC_ID vrrp instance"
	_CS="show router $_SVC_ID static-route"
	_C[$_i_cmd]="show router $_SVC_ID interface detail"
	_C[$_i_cmd+1]="show router $_SVC_ID arp"
	_C[$_i_cmd+2]="show router $_SVC_ID vrrp instance"
	_C[$_i_cmd+3]="show router $_SVC_ID static-route"
	_CG=$(echo -e "$_CG\r$_CI\r$_CA\r$_CV\r$_CS")
	let _i_cmd+=4
  done

  # PORTS
  _n_ports=$(cat data/ports.dat | grep "$_IP_NODE;" | grep ";Up;Yes;Up;" | wc -l | col -bx | sed 's/ //g')  
  for (( _i_ports=1; _i_ports<=$_n_ports; _i_ports++ )); do		
	_PORT_ID=$(cat data/ports.dat | grep "$_IP_NODE;" | grep ";Up;Yes;Up;" | head -$_i_ports | tail -1 | tr ";" "\n" | head -2 | tail -1)
	_CP="show port $_PORT_ID"
	_C[$_i_cmd]="show port $_PORT_ID"
	_CG=$(echo -e "$_CG\r$_CP")
	let _i_cmd+=1
  done

  _I_MAX=$(($_i_cmd-1))
  _TF="temp/operdata/$_IP_NODE.tmp"
  _STATUS=$(./sender.bash $_IP_NODE "$_CG" $_TF)
  if (( $_STATUS > 0 )); then
    for (( _i_cmd=1; _i_cmd<=$_I_MAX; _i_cmd++ )); do
      _P[$_i_cmd]=$(cat $_TF | grep -n "${_C[$_i_cmd]}" | tr ":" "\n" | head -1) 
    done
    _P[$_i_cmd]=$(cat $_TF | wc -l)
    _PT=$(cat $_TF | wc -l)

	_i_cmd=1
	# MONITOR PORTS
	# echo "$_IP_NODE:MONITOR-PORT" >> errors.log
	_n_ports=$(cat data/ports.dat | grep "$_IP_NODE;" | grep ";Up;Yes;Up;" | wc -l | col -bx | sed 's/ //g')  
    for (( _i_ports=1; _i_ports<=$_n_ports; _i_ports++ )); do		
	  _PORT_ID=$(cat data/ports.dat | grep "$_IP_NODE;" | grep ";Up;Yes;Up;" | head -$_i_ports | tail -1 | tr ";" "\n" | head -2 | tail -1)
	  if (( $(cat $_TF | head -$((${_P[$_i_cmd]}+1)) | grep "Utilization" | wc -l) > 0 )); then
		_IN_CAPAC=$(cat $_TF | head -$((${_P[$_i_cmd]}+1)) | tail -1 | tr ")" "\n" | tail -1 | awk '{print $1}' | tr -d "\r" | col -bx | sed 's/ //g')
		_EG_CAPAC=$(cat $_TF | head -$((${_P[$_i_cmd]}+1)) | tail -1 | tr ")" "\n" | tail -1 | awk '{print $2}' | tr -d "\r" | col -bx | sed 's/ //g')
		
		if (( $(cat "data/monitors.dat" 2> /dev/null | grep "$_IP_NODE;$_PORT_ID" | wc -l) < 1 )); then
		  echo "$_IP_NODE;$_PORT_ID;$_IN_CAPAC;$_EG_CAPAC" >> data/monitors.dat
		fi
	  fi
	  let _i_cmd+=1
    done

	# SVC ENDPOINTS
	# echo "$_IP_NODE:SVC-ENDPOINT" >> errors.log
    _n_svcs=$(cat data/svcs.dat | grep "$_IP_NODE;" | grep "pipe;Up;Up" | wc -l | col -bx | sed 's/ //g')  
    for (( _i_svcs=1; _i_svcs<=$_n_svcs; _i_svcs++ )); do		
	  _SVC_ID=$(cat data/svcs.dat | grep "$_IP_NODE;" | grep "pipe;Up;Up" | head -$_i_svcs | tail -1 | tr ";" "\n" | head -2 | tail -1)
	  _EP_NAME=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Endpoint name" | head -1 | tr ":" "\n" | tail -1 | tr -d "\r" | col -bx | sed 's/ //g')
	  _EP_REVERT_TIME=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Revert time" | head -1 | tr ":" "\n" | tail -1 | tr -d "\r" | col -bx | sed 's/ //g')
	  _EP_STBY_S_MASTER=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Standby Signaling Master" | head -1 | tr ":" "\n" | tail -1 | tr -d "\r" | col -bx | sed 's/ //g')
	  _EP_SSDP_ACT=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Tx Active" | head -1 | tr ":" "\n" | head -2 | tail -1 | tr -d "\r" | col -bx | sed 's/ //g')
	  _EP_SSDP_A=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Spoke-sdp" | head -1 | tr ":" "\n" | head -2 | tail -1 | tr -d "\r" | col -bx | sed 's/ //g')
	  _EP_SSDP_A_PREC=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Spoke-sdp" | head -1 | tr ":" "\n" | head -4 | tail -1 | cut -c1-1 | tr -d "\r" | col -bx | sed 's/ //g')
	  _EP_SSDP_B=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Spoke-sdp" | head -2 | tail -1 | tr ":" "\n" | head -2 | tail -1 | tr -d "\r" | col -bx | sed 's/ //g')
	  _EP_SSDP_B_PREC=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Spoke-sdp" | head -2 | tail -1 | tr ":" "\n" | head -4 | tail -1 | cut -c1-1 | tr -d "\r" | col -bx | sed 's/ //g')
	  
	  if (( $(echo $_EP_NAME | wc -c) > 1 )); then
	    if (( $(cat "data/svc_endpoints.dat" 2> /dev/null | grep "$_IP_NODE;$_SVC_ID" | wc -l) < 1 )); then
		  echo "$_IP_NODE;$_SVC_ID;$_EP_NAME;$_EP_REVERT_TIME;$_EP_STBY_S_MASTER;$_EP_SSDP_ACT;$_EP_SSDP_A;$_EP_SSDP_A_PREC;$_EP_SSDP_B;$_EP_SSDP_B_PREC" >> data/svc_endpoints.dat
	    fi
	  fi
	  let _i_cmd+=1
    done

	# SVC VPRN
	# echo "$_IP_NODE:SVC-VPRN" >> errors.log
    _n_svcs=$(cat data/svcs.dat | grep "$_IP_NODE;" | grep ";VPRN;Up;Up" | wc -l | col -bx | sed 's/ //g')  
    for (( _i_svcs=1; _i_svcs<=$_n_svcs; _i_svcs++ )); do		
	  _SVC_ID=$(cat data/svcs.dat | grep "$_IP_NODE;" | grep ";VPRN;Up;Up" | head -$_i_svcs | tail -1 | tr ";" "\n" | head -2 | tail -1)
	  _n_svc_ints=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "If Name" | wc -l | col -bx | sed 's/ //g')
	  for (( _i_svc_ints=1; _i_svc_ints<=$_n_svc_ints; _i_svc_ints++ )); do
		_PI_SVC_INT=$(cat -n $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "If Name" | head -$_i_svc_ints | tail -1 | awk '{print $1}' | tr -d "\t" | col -bx | sed 's/ //g')
		if (( $_i_svc_ints < $_n_svc_ints )); then
		  _PF_SVC_INT=$(($(cat -n $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "If Name" | head -$(($_i_svc_ints+1)) | tail -1 | awk '{print $1}' | tr -d "\t" | col -bx | sed 's/ //g')-1))
		else
		  _PF_SVC_INT=$((${_P[$_i_cmd+1]}-1))
		fi
	
		_INT_NAME=$(cat $_TF | tail -$(($_PT-$_PI_SVC_INT+1)) | head -$(($_PF_SVC_INT-$_PI_SVC_INT+1)) | grep "If Name" | tail -1 | tr ":" "\n" | tail -1 | cut -c 2- | tr -d "\r" | col -bx)
		_INT_IP=$(cat $_TF | tail -$(($_PT-$_PI_SVC_INT+1)) | head -$(($_PF_SVC_INT-$_PI_SVC_INT+1)) | grep "IP Addr/" | tail -1 | awk '{print $4}' | tr "/" "\n" | head -1 | tr -d "\r" | col -bx)
		_INT_MASK=$(cat $_TF | tail -$(($_PT-$_PI_SVC_INT+1)) | head -$(($_PF_SVC_INT-$_PI_SVC_INT+1)) | grep "IP Addr/" | tail -1 | awk '{print $4}' | tr "/" "\n" | head -2 | tail -1 | tr -d "\r" | col -bx)
		_INT_ADM_S=$(cat $_TF | tail -$(($_PT-$_PI_SVC_INT+1)) | head -$(($_PF_SVC_INT-$_PI_SVC_INT+1)) | grep "Admin State" | grep "Oper" | tail -1 | awk '{print $4}' | tr -d "\r" | col -bx)
		_INT_OPE_S=$(cat $_TF | tail -$(($_PT-$_PI_SVC_INT+1)) | head -$(($_PF_SVC_INT-$_PI_SVC_INT+1)) | grep "Admin State" | grep "Oper" | tail -1 | tr ":" "\n" | tail -1 | tr "/" "\n" | head -1 | sed 's/ //g' | tr -d "\r" | col -bx)

		_INT_SAP=$(cat $_TF | tail -$(($_PT-$_PI_SVC_INT+1)) | head -$(($_PF_SVC_INT-$_PI_SVC_INT+1)) | grep "SAP Id" | tail -1 | awk '{print $4}' | tr -d "\r" | col -bx)
		if (( $(echo $_INT_SAP | wc -c) < 2 )); then
		  _INT_SAP=$(cat $_TF | tail -$(($_PT-$_PI_SVC_INT+1)) | head -$(($_PF_SVC_INT-$_PI_SVC_INT+1)) | grep "Port Id" | tail -1 | awk '{print $4}' | tr -d "\r" | col -bx)
		fi
		if (( $(echo $_INT_SAP | grep rvpls | wc -l) > 0 )); then
		  _INT_SAP=$(cat $_TF | tail -$(($_PT-$_PI_SVC_INT+1)) | head -$(($_PF_SVC_INT-$_PI_SVC_INT+1)) | grep "VPLS Name" | awk '{print $4}' | tr -d "\r" | col -bx)
		fi

		if (( $(echo $_INT_SAP | grep ":" | wc -l) > 0 )); then
		  _PORT_VID=$(echo $_INT_SAP | tr ":" "\n" | tail -1 | tr -d "\r" | col -bx)
		else
		  _PORT_VID="N/A"
		fi
		_PORT_ID=$(echo $_INT_SAP | tr ":" "\n" | head -1 | tr -d "\r" | col -bx)
		
		if (( $(cat "data/svc_interfaces.dat" 2> /dev/null | grep "$_IP_NODE;$_SVC_ID;$_INT_NAME;" | wc -l) < 1 )); then
		  echo "$_IP_NODE;$_SVC_ID;$_INT_NAME;$_INT_IP;$_INT_MASK;$_PORT_ID;$_PORT_VID;$_INT_ADM_S;$_INT_OPE_S;$(_F_NET_ADD $_INT_IP $_INT_MASK)" >> data/svc_interfaces.dat
		fi
	  done
	  let _i_cmd+=1

	  _n_svc_arps=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "\[I]" | wc -l | col -bx | sed 's/ //g')
	  for (( _i_svc_arps=1; _i_svc_arps<=$_n_svc_arps; _i_svc_arps++ )); do
		_IP_HOST=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "\[I]" | head -$_i_svc_arps | tail -1 | awk '{print $1}' | tr -d "\r" | col -bx | sed 's/ //g')
		_MAC_HOST=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "\[I]" | head -$_i_svc_arps | tail -1 | awk '{print $2}' | tr -d "\r" | col -bx | sed 's/ //g')
		_ARP_TYPE=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "\[I]" | head -$_i_svc_arps | tail -1 | awk '{print $4}' | tr -d "\r" | col -bx | sed 's/ //g')
		_ARP_INT=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "\[I]" | head -$_i_svc_arps | tail -1 | awk '{print $5}' | tr -d "\r" | tr -d "*" | col -bx)
		_n_svc_arp_ints=$(cat "data/svc_interfaces.dat" | grep "$_ARP_INT" | wc -l | sed 's/ //g')
		for (( _i_svc_arp_ints=1; _i_svc_arp_ints<=$_n_svc_arp_ints; _i_svc_arp_ints++ )); do
		  _IP_GW=$(cat "data/svc_interfaces.dat" | grep "$_ARP_INT" | head -$_i_svc_arp_ints | tail -1 | tr ";" "\n" | head -4 | tail -1)
		  _MASK_GW=$(cat "data/svc_interfaces.dat" | grep "$_ARP_INT" | head -$_i_svc_arp_ints | tail -1 | tr ";" "\n" | head -5 | tail -1)
		  _NET_GW=$(_F_NET_ADD $_IP_GW $_MASK_GW )
		  _NET_HOST=$(_F_NET_ADD $_IP_HOST $_MASK_GW )
		  if (( $(echo $_NET_GW | grep $_NET_HOST | wc -l) > 0 )); then
			_ARP_INT=$(cat "data/svc_interfaces.dat" | grep "$_ARP_INT" | head -$_i_svc_arp_ints | tail -1 | tr ";" "\n" | head -3 | tail -1)
			break
		  fi
		done
		
		if (( $(cat "data/svc_arps.dat" 2> /dev/null | grep "$_IP_NODE;$_SVC_ID;$_IP_HOST;$_MAC_HOST" | wc -l) < 1 )); then
		  echo "$_IP_NODE;$_SVC_ID;$_IP_HOST;$_MAC_HOST;$_ARP_TYPE;$_ARP_INT" >> data/svc_arps.dat
		fi
      done
	  let _i_cmd+=1

	  _n_svc_vrrps=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Backup Addr" | wc -l | col -bx | sed 's/ //g')
	  for (( _i_svc_vrrps=1; _i_svc_vrrps<=$_n_svc_vrrps; _i_svc_vrrps++ )); do
		_PI_VRRP=$(($(cat -n $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "Backup Addr" | head -$_i_svc_vrrps | tail -1 | awk '{print $1}' | tr -d "\r" | tr -d "\t" | col -bx | sed 's/ //g')-2))
		_PF_VRRP=$(($_PI_VRRP+2))
		_INT_NAME=$(cat $_TF | tail -$(($_PT-$_PI_VRRP+1)) | head -$(($_PF_VRRP-$_PI_VRRP+1)) | head -1 | cut -c1-32 | tr -d "\r" | col -bx)
		_VRRP_ID=$(cat $_TF | tail -$(($_PT-$_PI_VRRP+1)) | head -$(($_PF_VRRP-$_PI_VRRP+1)) | head -1 | cut -c34- | awk '{print $1}' | sed 's/ //g' | tr -d "\r" | col -bx)
		_VRRP_ROLE=$(cat $_TF | tail -$(($_PT-$_PI_VRRP+1)) | head -$(($_PF_VRRP-$_PI_VRRP+1)) | head -1 | cut -c34- | awk '{print $4}' | sed 's/ //g' | tr -d "\r" | col -bx)
		_VRRP_PRIORITY=$(cat $_TF | tail -$(($_PT-$_PI_VRRP+1)) | head -$(($_PF_VRRP-$_PI_VRRP+1)) | head -1 | cut -c34- | awk '{print $5}' | sed 's/ //g' | tr -d "\r" | col -bx)
		_VRRP_ADDRESS=$(cat $_TF | tail -$(($_PT-$_PI_VRRP+1)) | head -$(($_PF_VRRP-$_PI_VRRP+1)) | tail -1 | tr ":" "\n" | tail -1 | sed 's/ //g' | tr -d "\r" | col -bx)

		if (( $(cat "data/svc_vrrps.dat" 2> /dev/null | grep "$_IP_NODE;$_SVC_ID;$_INT_NAME;$_VRRP_ID" | wc -l) < 1 )); then
		  echo "$_IP_NODE;$_SVC_ID;$_INT_NAME;$_VRRP_ID;$_VRRP_ROLE;$_VRRP_PRIORITY;$_VRRP_ADDRESS" >> data/svc_vrrps.dat
		fi
      done
	  let _i_cmd+=1

	  _n_svc_statics=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "/" | grep -v "\-\-\-\-" | grep -v "n/a" | wc -l | col -bx | sed 's/ //g')
	  for (( _i_svc_statics=1; _i_svc_statics<=$_n_svc_statics; _i_svc_statics++ )); do
		_PI_STATIC=$(cat -n $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep "/" | grep -v "\-\-\-\-" | grep -v "n/a" | head -$_i_svc_statics | tail -1 | awk '{print $1}' | tr -d "\r" | tr -d "\t" | col -bx | sed 's/ //g')
		_PF_STATIC=$(($_PI_STATIC+1))
		_INT_NAME=$(cat $_TF | tail -$(($_PT-$_PI_STATIC+1)) | head -$(($_PF_STATIC-$_PI_STATIC+1)) | tail -1 | cut -c48- | tr -d "\r" | col -bx)
		_NEXT_HOP=$(cat $_TF | tail -$(($_PT-$_PI_STATIC+1)) | head -$(($_PF_STATIC-$_PI_STATIC+1)) | tail -1 | awk '{print $1}' | sed 's/ //g' | tr -d "\r" | col -bx)
		_NETWORK=$(cat $_TF | tail -$(($_PT-$_PI_STATIC+1)) | head -$(($_PF_STATIC-$_PI_STATIC+1)) | head -1 | awk '{print $1}' | sed 's/ //g' | tr -d "\r" | col -bx)
		_PREFERENCE=$(cat $_TF | tail -$(($_PT-$_PI_STATIC+1)) | head -$(($_PF_STATIC-$_PI_STATIC+1)) | head -1 | awk '{print $4}' | sed 's/ //g' | tr -d "\r" | col -bx)
		_TYPE=$(cat $_TF | tail -$(($_PT-$_PI_STATIC+1)) | head -$(($_PF_STATIC-$_PI_STATIC+1)) | head -1 | awk '{print $5}' | sed 's/ //g' | tr -d "\r" | col -bx)
		_ACTIVE=$(cat $_TF | tail -$(($_PT-$_PI_STATIC+1)) | head -$(($_PF_STATIC-$_PI_STATIC+1)) | head -1 | awk '{print $6}' | sed 's/ //g' | tr -d "\r" | col -bx)
		
		if (( $(cat "data/svc_statics.dat" 2> /dev/null | grep "$_IP_NODE;$_SVC_ID;$_NETWORK;$_NEXT_HOP;" | wc -l) < 1 )); then
		  echo "$_IP_NODE;$_SVC_ID;$_NETWORK;$_NEXT_HOP;$_INT_NAME;$_TYPE;$_ACTIVE;$_PREFERENCE" >> data/svc_statics.dat
		fi
      done
	  let _i_cmd+=1
    done

	# PORTS
	# echo "$_IP_NODE:PORT" >> errors.log
	_n_ports=$(cat data/ports.dat | grep "$_IP_NODE;" | grep ";Up;Yes;Up;" | wc -l | col -bx | sed 's/ //g')  
    for (( _i_ports=1; _i_ports<=$_n_ports; _i_ports++ )); do		
	  _PORT_ID=$(cat data/ports.dat | grep "$_IP_NODE;" | grep ";Up;Yes;Up;" | head -$_i_ports | tail -1 | tr ";" "\n" | head -2 | tail -1)
	  if (( $(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep -i "Power" | wc -l) > 0 )); then
		_PORT_TX_VAL=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep -i "Power" | grep "Tx" | tr ")" "\n" | tail -1 | awk '{print $1}' | tr -d "\r" | tr "." "," | col -bx | sed 's/ //g')
		_PORT_TX_HAL=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep -i "Power" | grep "Tx" | tr ")" "\n" | tail -1 | awk '{print $2}' | tr -d "\r" | tr -d ! | tr "." "," | col -bx | sed 's/ //g')
		_PORT_TX_HWA=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep -i "Power" | grep "Tx" | tr ")" "\n" | tail -1 | awk '{print $3}' | tr -d "\r" | tr -d ! | tr "." "," | col -bx | sed 's/ //g')
		_PORT_TX_LAL=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep -i "Power" | grep "Tx" | tr ")" "\n" | tail -1 | awk '{print $4}' | tr -d "\r" | tr -d ! | tr "." "," | col -bx | sed 's/ //g')
		_PORT_TX_LWA=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep -i "Power" | grep "Tx" | tr ")" "\n" | tail -1 | awk '{print $5}' | tr -d "\r" | tr -d ! | tr "." "," | col -bx | sed 's/ //g')
		_PORT_RX_VAL=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep -i "Power" | grep "Rx" | tr ")" "\n" | tail -1 | awk '{print $1}' | tr -d "\r" | tr "." "," | col -bx | sed 's/ //g')
		_PORT_RX_HAL=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep -i "Power" | grep "Rx" | tr ")" "\n" | tail -1 | awk '{print $2}' | tr -d "\r" | tr -d ! | tr "." "," | col -bx | sed 's/ //g')
		_PORT_RX_HWA=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep -i "Power" | grep "Rx" | tr ")" "\n" | tail -1 | awk '{print $3}' | tr -d "\r" | tr -d ! | tr "." "," | col -bx | sed 's/ //g')
		_PORT_RX_LAL=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep -i "Power" | grep "Rx" | tr ")" "\n" | tail -1 | awk '{print $4}' | tr -d "\r" | tr -d ! | tr "." "," | col -bx | sed 's/ //g')
		_PORT_RX_LWA=$(cat $_TF | tail -$(($_PT-${_P[$_i_cmd]}+1)) | head -$((${_P[$(($_i_cmd+1))]}-${_P[$_i_cmd]})) | grep -i "Power" | grep "Rx" | tr ")" "\n" | tail -1 | awk '{print $5}' | tr -d "\r" | tr -d ! | tr "." "," | col -bx | sed 's/ //g')
		
		if (( $(cat "data/ports-power.dat" 2> /dev/null | grep "$_IP_NODE;$_PORT_ID" | wc -l) < 1 )); then
		  echo "$_IP_NODE;$_PORT_ID;$_PORT_TX_VAL;$_PORT_TX_HAL;$_PORT_TX_HWA;$_PORT_TX_LAL;$_PORT_TX_LWA;$_PORT_RX_VAL;$_PORT_RX_HAL;$_PORT_RX_HWA;$_PORT_RX_LAL;$_PORT_RX_LWA" >> data/ports-power.dat
		fi
	  fi
	  let _i_cmd+=1
    done
	
  fi
  
  #EGRESS-RATE
  #PORTS
  _n_ports=$(cat data/ports.dat | grep "$_IP_NODE;" | grep ";Up;Yes;Up;" | wc -l | col -bx | sed 's/ //g')  
  for (( _i_ports=1; _i_ports<=$_n_ports; _i_ports++ )); do		
	_PORT_ID=$(cat data/ports.dat | grep "$_IP_NODE" | grep ";Up;Yes;Up;" | head -$_i_ports | tail -1 | tr ";" "\n" | head -2 | tail -1)
	_EGRESS_RATE=$(cat $_TF | grep "Egress Rate" | head -$_i_ports | tail -1 | tr ":" "\n" | head -2 | tail -1 | tr " " "\n" | head -2 | tail -1)
	echo "$_IP_NODE;$_PORT_ID;$_EGRESS_RATE" >> data/Egress-Rate.dat
  done

  
  if (( $(ps -fea | grep basicdata.bash | grep -v grep | awk '{print $10}' | uniq | wc -l) < 2 )); then
    _TIME=$(date +%Y-%m-%d_%H:%M:%S_%A)
	echo "\nFIN : $_TIME" >> errors.log
	cp data/nodes.dat ../../.bin/
  fi

fi
