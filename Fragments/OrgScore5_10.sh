#!/bin/zsh

projectfolder=$(dirname "${0:A}")

source ${projectfolder}/Header.sh

CISLevel="2"
audit="5.10 Ensure system is set to hibernate (Automated)"
orgScore="OrgScore5_10"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo pmset -a standbydelayhigh 600 && sudo pmset -a standbydelaylow 600 && sudo pmset -a highstandbythreshold 90 && sudo pmset -a destroyfvkeyonstandby 1"

	hibernateValue=$(pmset -g | grep standbydelaylow 2>&1 | awk '{print $2}')
	macType=$(system_profiler SPHardwareDataType 2>&1 | grep -c MacBook)
	comment="Hibernate: Enabled"
	if [[ "$macType" -ge 0 ]]; then
		if [[ "$hibernateValue" == "" ]] || [[ "$hibernateValue" -gt 600 ]]; then
			countPassed=$((countPassed + 1))
			result="Passed"
		else 
			countFailed=$((countFailed + 1))
			result="Failed"
			comment="Hibernate: Disabled"
		fi
	else
		countPassed=$((countPassed + 1))
		result="Passed"
	fi
fi
printReport