#!/bin/sh

#  manageAirport.sh <mountPoint> <computerName> <currentUsername> <Airport Power: On|Off> <Require Admin: On|Off> <Join Mode: Automatic|Preferred|Ranked|Recent|Strongest> <Preferred Network: Keep|Purge|Isolate> <Favorite Network: "Network SSID">
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
#  Notes:  None of the macs I manage have more than one Airport device defined.  This code is not tested for multiple devices, nor for multiple Locations
#
#
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
## Must be run as root
##
##############################################################

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root!" 2>&1
    exit 1
fi  

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
Off) airportPower="off"
;;
OFF) airportPower="off"
;;
off) airportPower="off"
;;
*) echo  "Usage Error <Airport Power: On|Off>"
setFailedOptions=$(( setFailedOptions + 1))
;;
esac

## Error check and set variables for Require Admin
case "$5" in
On) requireAdmin="YES"
;;
on) requireAdmin="YES"
;;
ON) requireAdmin="YES"
;;
Off) requireAdmin="NO"
;;
OFF) requireAdmin="NO"
;;
off) requireAdmin="NO"
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
    echo "Usage: manageAirport.sh <mountPoint> <computerName> <currentUsername> <Airport Power: On|Off> <Require Admin: On|Off> <Join Mode: Automatic|Preferred|Ranked|Recent|Strongest> <Preferred Network: Keep|Purge|Isolate> <Favorite Network: \"Network SSID\">"
    exit 1
fi

##############################################################
##
## Production Code
##
##############################################################

## Determine the Wireless Device identifier
## All of my machines have exactly 1 airport card defined. Error checking is needed if you permit users to add or remove cards or services
device=$(/usr/sbin/networksetup -listallhardwareports | grep -E '(AirPort|Wi-Fi)' -A 1 | grep -o "en.")


## Set the desired preferences with the airport cli program
## Impliments <Join Mode: Automatic|Preferred|Ranked|Recent|Strongest> and <Require Admin: On|Off>
/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport prefs JoinMode=$joinMode RequireAdminNetworkChange=$requireAdmin RememberRecentNetworks=$requireAdmin RequireAdminPowerToggle=$requireAdmin
##add error checking


## Impliments <Preferred Network: Keep|Purge|Isolate> <Favorite Network: "Network SSID">
case "$preferredNetworkList" in
Purge) ## Clear all remembered networks
    tempStatus=$(/usr/sbin/networksetup -removeallpreferredwirelessnetworks $device)
;;
Isolate)
    ## Network SSIDs may contain white space, set the 'for' loop to parse at EOL.  Backup IFS to OIFS first
    OIFS=$IFS
    IFS=$'\n'

    #Retrieve all wireless networsk | remove leading whitespace | remove first line which is not a network
    #Then loop through the results
    for existingNetwork in $(/usr/sbin/networksetup -listpreferredwirelessnetworks $device | /usr/bin/awk '$1=$1' | /usr/bin/sed '1d')
    do
        if [[ "$existingNetwork" == "$favoriteNetwork" ]];
        then
            echo "Default network $existingNetwork. Skipping..."
        else
            echo "Found $existingNetwork... removing."
            /usr/sbin/networksetup -removepreferredwirelessnetwork $device $existingNetwork
            ##Testing on 10.8 indicates this can remove the last known netowork without error.  
        fi
    done
;;
Keep) echo "Keeping all preffered networks."
;;
*) echo  "Unknown case \"$preferredNetworkList\"- exiting..."
exit 1
;;
esac


## Set the Power Airport on or off
## Impliments <Airport Power: On|Off>
tempStatus=$(/usr/sbin/networksetup -setairportpower $device $airportPower)


exit 0