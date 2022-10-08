#!/bin/zsh
# shellcheck shell=bash

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source "${projectfolder}/Header.sh"

CISLevel="1"
audit="2.4.1 Ensure Remote Apple Events Is Disabled (Automated)"
orgScore="OrgScore2_4_1"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo /usr/sbin/systemsetup -setremoteappleevents off && sudo launchctl disable system/com.apple.AEServer"

	remoteAppleEvents=$(systemsetup -getremoteappleevents)
	if [[ "$remoteAppleEvents" == "Remote Apple Events: Off" ]]; then
		result="Passed"
		comment="Remote Apple Events: Disabled"
	else
		result="Failed"
		comment="Remote Apple Events: Enabled"
		# Remediation
		if [[ "${remediateResult}" == "enabled" ]]; then
			systemsetup -setremoteappleevents off
			launchctl disable system/com.apple.AEServer
			# re-check
			remoteAppleEvents=$(systemsetup -getremoteappleevents)
			if [[ "$remoteAppleEvents" == "Remote Apple Events: Off" ]]; then
				result="Passed After Remediation"
				comment="Remote Apple Events: Disabled"
			else
				result="Failed After Remediation"
			fi
		fi
	fi
fi
printReport