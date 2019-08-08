if (( $(ping -c 2 $1 | grep -w "100% packet loss" | wc -l)>0 )); then
  echo 0
  echo "$1;PING" >> fail.lst
else
    echo 1
fi

