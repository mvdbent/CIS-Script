#!/bin/zsh

projectfolder=$(dirname "${0:A}")

source ${projectfolder}/Header.sh

CISLevel="1"
audit="2.8 Disable Wake for network access (Automated)"
orgScore="OrgScore2_8"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo /usr/bin/pmset -a womp 0"
	
	wakeNetwork=$(pmset -g | awk '/womp/ { sum+=$2 } END {print sum}')
	if [[ "${wakeNetwork}" == "0" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="Wake for network access: Disabled"
	else
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="Wake for network access: Enabled"
	fi
fi
printReport