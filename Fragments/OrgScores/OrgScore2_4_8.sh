#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit="2.4.8 Ensure File Sharing Is Disabled (Automated)"
orgScore="OrgScore2_4_8"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo launchctl disable system/com.apple.smbd"
	smbEnabled=$(launchctl print-disabled system | grep -c '"com.apple.smbd" => false')
	if [[ "${smbEnabled}" == "0" ]]; then
		result="Passed"
		comment="File Sharing: Disabled"
	else
		result="Failed"
		comment="File Sharing: Enabled"
	# Remediation
		if [[ "${remediateResult}" == "enabled" ]]; then
			sudo launchctl disable system/com.apple.smbd
			killcfpref
			# re-check
			smbEnabled=$(launchctl print-disabled system | grep -c '"com.apple.smbd" => false')
			if [[ "${smbEnabled}" == "0" ]]; then
				result="Passed After Remediation"
				comment="File Sharing: Disabled"
			else
				result="Failed After Remediation"
			fi
		fi
	fi
fi
printReport