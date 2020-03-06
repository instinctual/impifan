#!/bin/bash
CPU1TEMP=$(ipmitool sdr type temperature | grep 0Eh |  cut -d \| -f5 | grep -Po '\d{2}')
CPU2TEMP=$(ipmitool sdr type temperature | grep 0Fh |  cut -d \| -f5 | grep -Po '\d{2}')
echo $CPU1TEMP
echo $CPU2TEMP
((AVGTEMP=(($CPU1TEMP+$CPU2TEMP)/2)))
echo $AVGTEMP
