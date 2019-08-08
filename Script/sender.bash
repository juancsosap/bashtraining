#!/bin/bash

./sender.exp $1 samadmin 54m4dm1n telnet "$2" >> $3
_STATUS=$(cat $3 | grep "sleep" | wc -l)
if (( _STATUS < 1 )); then
  ./sender.exp $1 samadmin 54m4dm1n telnet "$2" >> $3
  _STATUS=$(cat $3 | grep "sleep" | wc -l)
  if (( _STATUS < 1 )); then
    ./sender.exp $1 admin admin telnet "$2" >> $3
    _STATUS=$(cat $3 | grep "sleep" | wc -l)
  fi
fi
if (( _STATUS < 1 )); then
  echo "$1;CONN" >> fail.lst
fi
echo $_STATUS
