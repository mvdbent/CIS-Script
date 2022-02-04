#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit="Ensure Power Nap Is Disabled (Automated)"
orgScore="OrgScore2_9"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo /usr/bin/pmset -a powernap 0"
	
	powerNap=$(pmset -g custom | awk '/powernap/ { sum+=$2 } END {print sum}')
	if [[ "${powerNap}" == "0" ]]; then
		result="Passed"
		comment="Power Nap: Enabled"
	else 
		result="Failed"
		comment="Power Nap: Disabled"
	# Remediation
		if [[ "${remediateResult}" == "enabled" ]]; then
			sudo /usr/bin/pmset -a powernap 0
			# re-check
			powerNap=$(pmset -g custom | awk '/powernap/ { sum+=$2 } END {print sum}')
			if [[ "${powerNap}" == "0" ]]; then
				result="Passed After Remediation"
				comment="Power Nap: Enabled"
			else 
				result="Failed After Remediation"
			fi
		fi
	fi
fi
printReport