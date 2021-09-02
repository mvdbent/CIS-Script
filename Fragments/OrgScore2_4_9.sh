#!/bin/zsh

projectfolder=$(dirname "${0:A}")

source ${projectfolder}/Header.sh

CISLevel="1"
audit="2.4.9 Disable Remote Management (Automated)"
orgScore="OrgScore2_4_9"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -deactivate -stop"

	screenSharing=$(runAsUser launchctl list | grep com.apple.RemoteDesktop.agent | awk '{ print $1 }')
	if [[ "$screenSharing" == "-" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="Remote Management: Disabled"
	else
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="Remote Management: Enabled"
	fi
fi
printReport