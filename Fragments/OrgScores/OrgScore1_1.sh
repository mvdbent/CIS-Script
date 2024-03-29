#!/bin/zsh
# shellcheck shell=bash

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source "${projectfolder}/Header.sh"

CISLevel="1"
audit="1.1 Ensure All Apple-provided Software Is Current (Automated)"
orgScore="OrgScore1_1"
emptyVariables
method="Script"
remediate="Script > sudo /usr/sbin/softwareupdate --install --restart --recommended"
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	countAvailableSUS=$(/usr/bin/defaults read "/Library/Preferences/com.apple.SoftwareUpdate.plist" LastRecommendedUpdatesAvailable)
	if [[ "${countAvailableSUS}" == "0" ]]; then
		result="Passed"
		comment="Apple Software is Current"
	else
		result="Failed"
		comment="Available Updates: ${countAvailableSUS}, verify all Apple provided software is current"
	fi
fi
printReport