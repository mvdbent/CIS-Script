#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit="6.1.5 Ensure the Guest Home Folder Does Not Exist (Automated)"
orgScore="OrgScore6_1_5"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo rm -rf /Users/Guest"

	guestHomeFolder="$(ls /Users/ 2>&1 | grep -cx Guest)"
	if [[ "${guestHomeFolder}" == "0" ]]; then
		result="Passed"
		comment="Guest home folder: Not Available"
	else 
		result="Failed"
		comment="Guest home folder: Available"
		# Remediation
		if [[ "${remediateResult}" == "enabled" ]]; then
			rm -rf /Users/Guest
			# re-check
			guestHomeFolder="$(ls /Users/ 2>&1 | grep -cx Guest)"
			if [[ "${guestHomeFolder}" == "0" ]]; then
				result="Passed After Remediation"
				comment="Guest home folder: Not Available"
			else
				result="Failed After Remediation"
			fi
		fi
	fi
fi
printReport