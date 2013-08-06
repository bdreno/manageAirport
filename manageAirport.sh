#!/bin/sh

#  serviceWiFiPrep.sh <mountPoint> <computerName> <currentUsername> <Airport Power: On|Off> <Require Admin: On|Off> <Join Mode: Automatic|Preferred|Ranked|Recent|Strongest> <Preferred Network: Keep|Purge|Isolate> <Favorite Network: "Network SSID">
#
#  All fields are requried unless otherwise noted
#   <mountPoint>    Reserved for the JSS
#   <computerName>  Reserved for the JSS
#   <currentUsername>   Reserved for the JSS
#   <Airport Power: On|Off> Ensures the Network Adaptor is powered on or off
#   <Require Admin: On|Off> Requires or disalbes admin access to change all wireless settings
#   <Join Mode: Automatic|Preferred|Ranked|Recent|Strongest> Set the join moid
#   <Preferred Network List: Keep|PurgeAll|Purge>  If Keep, leaves the Preferred Network list intact, PurgeAll Remove all saved netowrks, or Purge all but   
#   <Favorite Network: "Network SSID">  Required only if "Preffered Network List" was set to Purge.  All networks not matching this SSID will be removed from the preferred network list.   
#
#
#  Created by Bradley D. Reno on 7/23/13.
#

##############################################################
##
## Define base variables
##
##############################################################
setFailedOptions=0
airportPower=""
requireAdmin=""
joinMode=""
preferredNetworkList=""
favoriteNetwork=""

##############################################################
##
## Error check input
##
##############################################################

## Error check and set variables for Airport Power
case "$4" in
On) airportPower="on"
;;
on) airportPower="on"
;;
ON) airportPower="on"
;;
Off) airportPower="on"
;;
OFF) airportPower="on"
;;
off) airportPower="on"
;;
*) echo  "Usage Error <Airport Power: On|Off>"
setFailedOptions=$(( setFailedOptions + 1))
;;
esac

## Error check and set variables for Require Admin
case "$5" in
On) requireAdmin="on"
;;
on) requireAdmin="on"
;;
ON) requireAdmin="on"
;;
Off) requireAdmin="on"
;;
OFF) requireAdmin="on"
;;
off) requireAdmin="on"
;;
*) echo  "Usage Error <Require Admin: On|Off>"
setFailedOptions=$(( setFailedOptions + 1))
;;
esac

## Error check and set variables for Join Mode
case "$6" in
Automatic) joinMode="Automatic"
;;
Preferred) joinMode="Preferred"
;;
Ranked) joinMode="Ranked"
;;
Recent) joinMode="Recent"
;;
Strongest) joinMode="Strongest"
;;
*) echo  "Usage Error <Join Mode: Automatic|Preferred|Ranked|Recent|Strongest>"
setFailedOptions=$(( setFailedOptions + 1))
;;
esac

## Error check and set variables for Preferred Network
case "$7" in
Keep) preferredNetworkList="Keep"
;;
Purge) preferredNetworkList="Purge"
;;
Isolate) preferredNetworkList="Isolate"
;;
*) echo  "Usage Error <Preferred Network: Keep|Purge|Isolate>"
setFailedOptions=$(( setFailedOptions + 1))
;;
esac

## Error check and set variables for Favorite Network
if [[ "$preferredNetworkList" == "Isolate" && "$8" == "" ]]; then
    echo  "Usage Error <Favorite Network: \"Network SSID\">"
    setFailedOptions=$(( setFailedOptions + 1))
else
    favoriteNetwork="$8"
fi



## Exit the script if any variables were set incorrectly
if [[ $setFailedOptions > 0 ]]; then
    echo "Found $setFailedOptions errors."
    echo "Exiting..."
    echo "Usage: serviceWiFiPrep.sh <mountPoint> <computerName> <currentUsername> <Airport Power: On|Off> <Require Admin: On|Off> <Join Mode: Automatic|Preferred|Ranked|Recent|Strongest> <Preferred Network: Keep|Purge|Isolate> <Favorite Network: \"Network SSID\">"
    exit 1
fi

##############################################################
##
## Production Code
##
##############################################################
## Disable the remember networks feature
###set the desired preferences
#/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport prefs JoinMode=Automatic RequireAdminNetworkChange=YES RememberRecentNetworks=YES RequireAdminPowerToggle=YES


## Determine the Wireless Device identifier
device=$(/usr/sbin/networksetup -listallhardwareports | grep -E '(AirPort|Wi-Fi)' -A 1 | grep -o "en.")

## Clear all remembered networks
#tempStatus=$(networksetup -removeallpreferredwirelessnetworks $device)

## Network SSIDs may contain white space, set the 'for' loop to parse at EOL.  
#IFS=$'\n'

#Retrieve all wireless networsk | remove leading whitespace | remove first line which is not a network
#Then loop through the results
#for preferredNetwork in $(/usr/sbin/networksetup -listpreferredwirelessnetworks $device | /usr/bin/awk '$1=$1' | /usr/bin/sed '1d')
#do
#    if [ $preferredNetwork == "UofM Secure" ];
#    then
#        echo "Default network $preferredNetwork. Skipping..."
#    else
#        echo "Found $preferredNetwork... removing."
#        /usr/sbin/networksetup -removepreferredwirelessnetwork  $device $preferredNetwork
#    fi
#done


## Set the Power Airport on or off
tempStatus=$(/usr/sbin/networksetup -setairportpower $device $airportPower)


exit 0