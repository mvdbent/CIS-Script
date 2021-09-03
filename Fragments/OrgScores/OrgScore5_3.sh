#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

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
		result="Passed"
		comment="The sudo timeout period is reduced: ${sudoTimeout}"
	else 
		result="Failed"
		comment="Reduce the sudo timeout period"
	fi
fi
printReport