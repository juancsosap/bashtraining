#!/bin/bash

if [ -f tempnodes.lst ];
then
   rm tempnodes.lst
fi



ls -la temp/basicdata/ | awk '{print $9}' >> tempnodes.lst


if [ -f VPLSXYZ.dat ];
then
   rm VPLSXYZ.dat
fi


_l_nodes=$(cat tempnodes.lst | tr ";" " " | awk '{print $1}' | tr "\n" " ")
_n_nodes=$(cat tempnodes.lst | wc -l)
for (( _i_nodes=4; _i_nodes<=_n_nodes; _i_nodes++ )); do
	
	_ip_node=$( cat tempnodes.lst | head -$_i_nodes | tail -1)
	_TF="temp/basicdata/$_ip_node"
	#_TF="temp/basicdata/172.26.32.1.tmp"
	#echo "$_TF"
	_n_HorizonGroup=$( cat $_TF | grep "vpls" | grep "customer 1 create" | wc -l )
	for (( _i_HorizonGroup=1; _i_HorizonGroup<=$_n_HorizonGroup; _i_HorizonGroup++ )); do	
		_total_lines_HG=$( cat $_TF | wc -l)
		_line_HorizonGroup_uno=$( cat -n $_TF | grep "vpls" | grep "customer 1 create" | head -$_i_HorizonGroup | tail -1 | tr " " "\n" | head -2 | tail -1 )
		_VPLS_HorizonGroup=$( cat -n $_TF | grep "vpls" | grep "customer 1 create" | head -$_i_HorizonGroup | tail -1 | tr " " "\n" | head -11 | tail -1 )
		
		if(($_i_HorizonGroup<$_n_HorizonGroup));then
			_line_HorizonGroup_dos=$( cat -n $_TF | grep "vpls" | grep "customer 1 create" | head -$(($_i_HorizonGroup+1)) | tail -1 | tr " " "\n" | head -2 | tail -1 )
			_HorizonGroup=$( cat -n $_TF | tail -$(($_total_lines_HG-$_line_HorizonGroup_uno+1)) | head -$(($_line_HorizonGroup_dos-$_line_HorizonGroup_uno)) | grep "split-horizon-group " | grep -v "spoke-sdp " | tr " " "0" | tr "0-9" "\n" | head -20 | tail -1 )
		else
			#_Search=$( cat -n $_TF | grep "admin display" | grep "match" -v | tr "a-zA-Z " "\n" | head -2 | tail -1 )
			_HorizonGroup=$( cat -n $_TF | tail -$(($_total_lines_HG-$_line_HorizonGroup_uno+1)) | grep "split-horizon-group " | grep -v "spoke-sdp " | tr " " "0" | tr "0-9" "\n" | head -20 | tail -1 )
		fi
		echo "$_NODE_NAME;$_IP_NODE;$_NODE_TYPE;$_VPLS_HorizonGroup;$_HorizonGroup" >> VPLSXYZ.dat
	done

done
rm tempnodes.lst



