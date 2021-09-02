#!/bin/zsh

projectfolder=$(dirname "${0:A}")

source ${projectfolder}/Header.sh

CISLevel="1"
audit="5.3 Reduce the sudo timeout period (Automated)"
orgScore="OrgScore5_3"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	remediate='Script > echo "Defaults timestamp_timeout=0" >> /etc/sudoers'

	sudoTimeout="$(ls /etc/sudoers.d/ 2>&1 | grep -c timestamp )"
	if [[ "${sudoTimeout}" == "0" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="The sudo timeout period is reduced: ${sudoTimeout}"
	else 
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="Reduce the sudo timeout period"
	fi
fi
printReport