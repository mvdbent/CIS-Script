#!/bin/zsh

projectfolder=$(dirname "${0:A}")

source ${projectfolder}/Header.sh

CISLevel="1"
audit="2.4.6 Disable DVD or CD Sharing (Automated)"
orgScore="OrgScore2_4_6"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.ODSAgent.plist"

	discSharing=$(launchctl list | grep -Ec ODSAgent)
	if [[ "${discSharing}" == "0" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="DVD or CD Sharing: Disabled"
	else
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="DVD or CD Sharing: Enabled"
	fi
fi
printReport