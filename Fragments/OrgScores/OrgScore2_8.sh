#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit="2.8 Ensure Wake for Network Access Is Disabled (Automated)"
orgScore="OrgScore2_8"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo /usr/bin/pmset -a womp 0"
	
	wakeNetwork=$(pmset -g custom | awk '/womp/ { sum+=$2 } END {print sum}')
	if [[ "${wakeNetwork}" == "0" ]]; then
		result="Passed"
		comment="Wake for network access: Disabled"
	else
		result="Failed"
		comment="Wake for network access: Enabled"
		# Remediation
		if [[ "${remediateResult}" == "enabled" ]]; then
			pmset -a womp 0
		# re-check
			wakeNetwork=$(pmset -g custom | awk '/womp/ { sum+=$2 } END {print sum}')
			if [[ "${wakeNetwork}" == "0" ]]; then
				result="Passed After Remediation"
				comment="Wake for network access: Disabled"
			else
				result="Failed After Remediation"
			fi
		fi
	fi
fi
printReport