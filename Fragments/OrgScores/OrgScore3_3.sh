#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit="3.3 Retain install.log for 365 or more days with no maximum size (Automated)"
orgScore="OrgScore3_3"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > add 'ttl=365' to /etc/asl/com.apple.install"

	installRetention="$(grep -c ttl=365 /etc/asl/com.apple.install)"
	if [[ "${installRetention}" = "1" ]]; then
		result="Passed"
		comment="Retain install.log: 365 or more days"
	else 
		result="Failed"
		comment="Retain install.log: Less than 365 days"
		# Remediation
		if [[ "${remediateResult}" == "enabled" ]]; then
			sudo mv /etc/asl/com.apple.install{,.old}
			sudo sed '$s/$/ ttl=365/' /etc/asl/com.apple.install.old > /etc/asl/com.apple.install
			sudo chmod 644 /etc/asl/com.apple.install
			sudo chown root:wheel /etc/asl/com.apple.install			
		#re-check
			installRetention="$(grep -c ttl=365 /etc/asl/com.apple.install)"
			if [[ "${installRetention}" = "1" ]]; then
				result="Passed After Remediation"
				comment="Retain install.log: 365 or more days"
			else
				result="Failed After Remediation"
			fi
		fi
	fi
fi
printReport