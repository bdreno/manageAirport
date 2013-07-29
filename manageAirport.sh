#!/bin/sh

#  serviceWiFiPrep.sh
#  
#
#  Created by Bradley D. Reno on 7/23/13.
#
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