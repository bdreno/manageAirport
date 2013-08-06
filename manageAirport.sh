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

#Define base variables
airportPower=""
requireAdmin=""
joinMode=""
preferredNetworkList=""
favoriteNetwork=""


if [ "$4" == "" && "$4" != "On" && "$4" != "on" && "$4" != "ON" && "$4" != "Off" && "$4" != "OFF" && "$4" != "off"]; then
    echo "Usage Error <Airport Power: On|Off>"
    exit 1
else
    airportPower="on"
fi

if [ "$5" == "" ]; then
echo "Must supply a Password in variables 5"
exit 1
fi


## Disable the remember networks feature
###set the desired preferences
/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport prefs JoinMode=Automatic RequireAdminNetworkChange=YES RememberRecentNetworks=YES RequireAdminPowerToggle=YES


## Determine the Wireless Device identifier
device=$(networksetup -listallhardwareports | grep -E '(AirPort|Wi-Fi)' -A 1 | grep -o "en.")

## ensure power is on
tempStatus=$(networksetup -setairportpower $device on)

## Clear all remembered networks
#tempStatus=$(networksetup -removeallpreferredwirelessnetworks $device)

## Network SSIDs may contain white space, set the 'for' loop to parse at EOL.  
IFS=$'\n'

#Retrieve all wireless networsk | remove leading whitespace | remove first line which is not a network
#Then loop through the results
for preferredNetwork in $(/usr/sbin/networksetup -listpreferredwirelessnetworks $device | /usr/bin/awk '$1=$1' | /usr/bin/sed '1d')
do
    if [ $preferredNetwork == "UofM Secure" ];
    then
        echo "Default network $preferredNetwork. Skipping..."
    else
        echo "Found $preferredNetwork... removing."
        /usr/sbin/networksetup -removepreferredwirelessnetwork  $device $preferredNetwork
    fi
done


exit 0