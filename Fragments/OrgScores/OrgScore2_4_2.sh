#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit="2.4.2 Disable Internet Sharing (Automated)"
orgScore="OrgScore2_4_2"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.MCX > forceInternetSharingOff=true"

	comment="Internet Sharing: Disabled"
	if [[ -e /Library/Preferences/SystemConfiguration/com.apple.nat.plist ]]; then
		natAirport=$(/usr/libexec/PlistBuddy -c "print :NAT:AirPort:Enabled" /Library/Preferences/SystemConfiguration/com.apple.nat.plist > /dev/null 2>&1)
		natEnabled=$(/usr/libexec/PlistBuddy -c "print :NAT:Enabled" /Library/Preferences/SystemConfiguration/com.apple.nat.plist > /dev/null 2>&1)
		natPrimary=$(/usr/libexec/PlistBuddy -c "print :NAT:PrimaryInterface:Enabled" /Library/Preferences/SystemConfiguration/com.apple.nat.plist > /dev/null 2>&1)
		forwarding=$(sysctl net.inet.ip.forwarding 2>&1| awk '{ print $NF }')
		if [[ "$natAirport" != "1" ]] || [[ "$natEnabled" != "1" ]] || [[ "$natPrimary" != "1" ]] || [[ "$forwarding" != "1" ]]; then
			result="Passed"
		else
			result="Failed"
			comment="Internet Sharing: Enabled"
		fi
	fi
	result="Passed"
fi
printReport