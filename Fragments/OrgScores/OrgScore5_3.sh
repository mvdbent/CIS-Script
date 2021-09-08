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
	method="Script"
	remediate='Script > echo "Defaults timestamp_timeout=0" >> /etc/sudoers'

	sudoTimeout="$(grep -c "timestamp_timeout=" /etc/sudoers)"
	if [[ "${sudoTimeout}" == "1" ]]; then
		result="Passed"
		comment="The sudo timeout period is reduced"
	else 
		result="Failed"
		comment="Reduce the sudo timeout period"
		# Remediation
		if [[ "${remediateResult}" == "enabled" ]]; then
			echo "Defaults timestamp_timeout=0" >> /etc/sudoers
			# re-check
			sudoTimeout="$(grep -c "timestamp_timeout=" /etc/sudoers)"
			if [[ "${sudoTimeout}" == "1" ]]; then
				result="Passed After Remediation"
				comment="The sudo timeout period is reduced to 0"
			else
				result="Failed After Remediation"
			fi
		fi
	fi
fi
printReport