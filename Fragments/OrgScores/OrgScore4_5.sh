#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit="4.5 Ensure NFS Server Is Disabled (Automated)"
orgScore="OrgScore4_5"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo launchctl disable system/com.apple.nfsd && sudo rm /etc/exports"

	httpServer=$(launchctl print-disabled system 2>&1 | grep -c '"com.apple.nfsd" => false')
	if [[ "${httpServer}" != "1" ]]; then
		result="Passed"
		comment="NFS server service: Disabled"
	else 
		result="Failed"
		comment="NFS server service: Enabled"
		# Remediation
		if [[ "${remediateResult}" == "enabled" ]]; then
			launchctl disable system/com.apple.nfsd
			rm /etc/exports
			# re-check
			httpServer=$(launchctl print-disabled system 2>&1 | grep -c '"com.apple.nfsd" => false')
			if [[ "${httpServer}" != "1" ]]; then
				result="Passed After Remediation"
				comment="NFS server service: Disabled"
			else
				result="Failed After Remediation"
			fi
		fi
	fi
fi
printReport