#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit="2.4.6 Ensure DVD or CD Sharing Is Disabled (Automated)"
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
		result="Passed"
		comment="DVD or CD Sharing: Disabled"
	else
		result="Failed"
		comment="DVD or CD Sharing: Enabled"
	# Remediation
		if [[ "${remediateResult}" == "enabled" ]]; then
			sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.ODSAgent.plist
			# re-check
			discSharing=$(launchctl list | grep -Ec ODSAgent)
			if [[ "${discSharing}" == "0" ]]; then
				result="Passed After Remediation"
				comment="DVD or CD Sharing: Disabled"
			else
				result="Failed After Remediation"
			fi
		fi
		
	fi
fi
printReport