#!/bin/zsh

projectfolder=$(dirname "${0:A}")

source ${projectfolder}/Header.sh

CISLevel="1"
audit="1.1 Verify all Apple-provided software is current (Automated)"
orgScore="OrgScore1_1"
emptyVariables
method="Script"
remediate="Script > sudo /usr/sbin/softwareupdate --install --restart --recommended"
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	countAvailableSUS=$(softwareupdate -l 2>&1 | grep -c "*")
	if [[ "${countAvailableSUS}" == "0" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="Apple Software is Current"
	else
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="Available Updates: ${countAvailableSUS}, verify all Apple provided software is current"
	fi
fi
printReport