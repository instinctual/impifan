#!/bin/bash
# ----------------------------------------------------------------------------------
# Every 20 seconds this script checks the temperature reported by the ambient temperature sensor,
# and if deemed too high sends the raw IPMI command to adjust the fan speed on the R610 server.
# It also sends healthcheck pings to a healthchecks.io service.
#
#
# Requires:
# ipmitool – apt-get install ipmitool
# slacktee.sh – https://github.com/course-hero/slacktee
# ----------------------------------------------------------------------------------
# Set the state of Emergency (is it too hot or not)
EMERGENCY=false
NOTIFY=true

# IPMI SETTINGS:
# DEFAULT IP: 192.168.0.120
IPMIHOST=192.168.108.201 # <IP Address of the iDRAC on the Server>
IPMIUSER=root # <User for the iDRAC>
IPMIPW=S*13qW6R+q@HQK2d07/- # <Password for the iDRAC


# TEMPERATURE
# Change this to the temperature in celcius you are comfortable with.
# If the temperature goes above the set degrees it will send raw IPMI command to enable dynamic fan control
# According to iDRAC Min Warning is 42C and Failure (shutdown) is 47C
IdleTemp="30"
LowTemp=( "31" "32" "33" )
MidTemp=( "34" "35" "36" "37" )
HighTemp=( "38" "39" "40" "41" )
MAXTEMP="42"



# Last Octal controls values to know
# Query Fan speeds
# ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW sdr type fan
#
# Fan Power Percentages
# 0x00 = 0%
# 0x64 = 100%
#
# R7910 RPM values

# 5 =  2400  RPM 5%   
# a =  3360  RPM 10% 
# 0f = 4080  RPM 15%
# 14 = 4920  RPM 20%
# 19 = 5640  RPM 25% 
# 1e = 6480  RPM 30% 
# 23 = 7200  RPM 35% 
# 28 = 8040  RPM 40%
# 2d = xxxx  RPM 45%
# 32 = xxxx  RPM 50%
# 3c = xxxx  RPM 60%
# 50 = xxxxx RPM 80%

# 10%
function FanLevel10()
{
  echo "Activating manual fan speeds 10%"
  ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW raw 0x30 0x30 0x01 0x00
  ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW raw 0x30 0x30 0x02 0xff 0xa
}

# 15%
function FanLevel15()
{
  echo "Activating manual fan speeds 15%"
  ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW raw 0x30 0x30 0x01 0x00
  ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW raw 0x30 0x30 0x02 0xff 0x0f
}

# 20%
function FanLevel20()
{
  echo "Activating manual fan speeds 20%"
  ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW raw 0x30 0x30 0x01 0x00
  ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW raw 0x30 0x30 0x02 0xff 0x14
}

# 25%
function FanLevel25()
{
  echo "Activating manual fan speeds 25%"
  ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW raw 0x30 0x30 0x01 0x00
  ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW raw 0x30 0x30 0x02 0xff 0x19
}


# 30%
function FanLevel30()
{
  echo "Activating manual fan speeds 30%"
  ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW raw 0x30 0x30 0x01 0x00
  ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW raw 0x30 0x30 0x02 0xff 0x1e
}

# 35%
function FanLevel35()
{
  echo "Activating manual fan speeds 35%"
  ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW raw 0x30 0x30 0x01 0x00
  ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW raw 0x30 0x30 0x02 0xff 0x23
}

# 40%
function FanLevel35()
{
  echo "Activating manual fan speeds 40%"
  ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW raw 0x30 0x30 0x01 0x00
  ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW raw 0x30 0x30 0x02 0xff 0x28
}

# Auto-controled
function FanAuto()
{
  echo "Dynamic fan control Active ($CurrentTemp C)"
  ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW raw 0x30 0x30 0x01 0x01
}

function gettemp()
{
  TEMP=$(ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW sdr type temperature | grep Exhaust | cut -d \| -f5 |grep -Po '\d{2}')
  echo "$TEMP"
}


# Helper function for does an array contain a this value
array_contains () {
    local array="$1[@]"
    local seeking=$2
    for element in "${!array}"; do
        if [[ $element == $seeking ]]; then
            return 1
        fi
    done
    return 0
}

# Start by setting the fans to default low level
#echo "Info: Activating manual fan speeds 10%"
#ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW raw 0x30 0x30 0x01 0x00
#ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW raw 0x30 0x30 0x02 0xff 0x0f
#FanLevel15

while :
do
  CurrentTemp=$(gettemp)
  echo "Current System Board Exhaust Temp: $CurrentTemp Celcius"
  echo " "
  if [[ $CurrentTemp > $MAXTEMP ]]; then
    FanAuto
  fi

  if [[ $CurrentTemp < $IdleTemp ]]; then
    FanLevel15
  fi

  array_contains LowTemp $CurrentTemp
  result=$(echo $?)
  if [ "$result" -eq 1 ] ; then
    FanLevel20
  fi

  array_contains MidTemp $CurrentTemp
  result=$(echo $?)
  if [ "$result" -eq 1 ] ; then
    FanLevel30
  fi

  array_contains HighTemp $CurrentTemp
  result=$(echo $?)
  if [ "$result" -eq 1 ] ; then
    FanLevel35
  fi

  sleep 30
done
