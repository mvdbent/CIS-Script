#!/bin/zsh

projectfolder=$(dirname "${0:A}")

source ${projectfolder}/Header.sh

CISLevel="2"
audit="5.18 System Integrity Protection status (Automated)"
orgScore="OrgScore5_18"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo /usr/bin/csrutil enable"

	sipEnabled="$(csrutil status 2>&1 | awk '{print $5}')"
	if [[ "${sipEnabled}" == "enabled." ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="System Integrity Protection: Enabled"
	else 
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="System Integrity Protection: Disabled"
	fi
fi
printReport