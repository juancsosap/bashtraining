#!/bin/bash

kill -9 $(ps -fea | grep sender | grep -v grep | awk '{print $2}' | tr "\n" " ")
kill -9 $(ps -fea | grep ping | grep -v grep | awk '{print $2}' | tr "\n" " ")
kill -9 $(ps -fea | grep basicdata.bash | grep -v grep | awk '{print $2}' | tr "\n" " ")
