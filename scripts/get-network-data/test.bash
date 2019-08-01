#!/bin/bash

ps -fea | grep basicdata.bash | grep -v grep | awk '{print $10}' | uniq | wc -l
