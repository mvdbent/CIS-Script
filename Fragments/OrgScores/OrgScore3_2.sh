#!/bin/zsh
# shellcheck shell=bash

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source "${projectfolder}/Header.sh"

CISLevel="2"
audit="3.2 Ensure Security Auditing Flags Are Configured Per Local Organizational Requirements (Automated)"
orgScore="OrgScore3_2"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo /usr/bin/sed -i.bak '/^flags/ s/$/,ad/' /etc/security/audit_control /usr/sbin/audit -s"

	auditFlags="$(grep -c "^flags:" /etc/security/audit_control)"
	if [[ "${auditFlags}" == "1" ]]; then
		result="Passed"
		comment="Security Auditing Flags: Enabled"
	else 
		result="Failed"
		comment="Security Auditing Flags: Disabled"
		# Remediation
		if [[ "${remediateResult}" == "enabled" ]]; then
			/usr/bin/sed -i.bak '/^flags/ s/$/,ad/' /etc/security/audit_control /usr/sbin/audit -s
			#re-check
			auditFlags="$(grep -c "^flags:" /etc/security/audit_control)"
			if [[ "${auditFlags}" == "1" ]]; then
				result="Passed After Remediation"
				comment="Security Auditing Flags: Enabled"
			else 
				result="Failed After Remediation"
			fi
		fi
	fi
fi
printReport