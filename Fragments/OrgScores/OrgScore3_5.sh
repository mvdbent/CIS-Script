#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit="3.5 Control access to audit records (Automated)"
orgScore="OrgScore3_5"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo chown -R root $(/usr/bin/grep '^dir' /etc/security/audit_control | /usr/bin/awk -F: '{print $2}')"

	controlAccess=$(/usr/bin/grep '^dir' /etc/security/audit_control | awk -F: '{print $2}')
	accessCheck=$(find "${controlAccess}" | awk '{s+=$3} END {print s}')
	ownership=$(ls -ld /etc/security/audit_control | cut -d' ' -f4 -f6)
	if [[ "${accessCheck}" == "0" ]] && [[ "${ownership}" == "root wheel" ]]; then
		result="Passed"
		comment="Control access to audit records: Correct ownership"
	else 
		result="Failed"
		comment="Control access to audit records: Incorrect ownership"
		# Remediation
		if [[ "${remediateResult}" == "enabled" ]]; then
			chown -R root:wheel /var/audit
			chmod -R 440 /var/audit
			chown root:wheel /etc/security/audit_control
			chmod 400 /etc/security/audit_control
			# re-check
			controlAccess=$(grep '^dir' /etc/security/audit_control | awk -F: '{print $2}')
			accessCheck=$(find "${controlAccess}" | awk '{s+=$3} END {print s}')
			ownership=$(ls -ld /etc/security/audit_control | cut -d' ' -f4 -f6)
			if [[ "${accessCheck}" == "0" ]] && [[ "${ownership}" == "root wheel" ]]; then
				result="Passed After Remediation"
				comment="Control access to audit records: Correct ownership"
			else
				result="Failed After Remediation"
			fi
		fi
	fi
fi
printReport