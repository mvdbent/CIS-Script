#!/bin/zsh

projectfolder=$(dirname "${0:A}")

source ${projectfolder}/Header.sh

CISLevel="1"
audit="6.1.5 Remove Guest home folder (Automated)"
orgScore="OrgScore6_1_5"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo rm -rf /Users/Guest"

	guestHomeFolder="$(ls /Users/ 2>&1 | grep -c Guest)"
	if [[ "${guestHomeFolder}" == "0" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="Guest home folder: Not Available"
	else 
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="Guest home folder: Available"
	fi
fi
printReport