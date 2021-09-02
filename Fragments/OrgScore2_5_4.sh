#!/bin/zsh

projectfolder=$(dirname "${0:A}")

source ${projectfolder}/Header.sh

CISLevel="2"
audit="2.5.4 Enable Location Services (Automated)"
orgScore="OrgScore2_5_4"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo /usr/bin/defaults write /var/db/locationd/Library/Preferences/ByHost/com.apple.locationd LocationServicesEnabled -bool true && sudo /bin/launchctl kickstart -k system/com.apple.locationd"
	
	locationServices=$(defaults read /var/db/locationd/Library/Preferences/ByHost/com.apple.locationd.plist LocationServicesEnabled 2>&1)
	if [[ "${locationServices}" != "0" ]]; then
		result="Passed"
		comment="Location Services: Enabled"
	else 
		result="Failed"
		comment="Location Services: Disabled"
	fi
fi
printReport