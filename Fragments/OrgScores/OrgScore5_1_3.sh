#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit="5.1.3 Ensure Apple Mobile File Integrity Is Enabled (Automated)"
orgScore="OrgScore5_1_3"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate='Script > sudo /usr/sbin/nvram boot-args=""'

	mobileFileIntegrity="$(nvram -p | grep -c "amfi_get_out_of_my_way=1")"
	if [[ "${mobileFileIntegrity}" == "0" ]]; then
		result="Passed"
		comment="Apple Mobile File Integrity: Enabled"
	else 
		result="Failed"
		comment="Apple Mobile File Integrity: Disabled"
		# Remediation
		if [[ "${remediateResult}" == "enabled" ]]; then
			nvram boot-args=""
			# re-check
			mobileFileIntegrity="$(nvram -p | grep -c "amfi_get_out_of_my_way=1")"
			if [[ "${mobileFileIntegrity}" == "0" ]]; then
				result="Passed After Remediation"
				comment="Apple Mobile File Integrity: Enabled"
			else
				result="Failed After Remediation"
			fi
		fi
	fi
fi
printReport