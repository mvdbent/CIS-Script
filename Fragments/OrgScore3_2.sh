#!/bin/zsh

projectfolder=$(dirname "${0:A}")

source ${projectfolder}/Header.sh

CISLevel="2"
audit="3.2 Configure Security Auditing Flags per local organizational requirements (Manual)"
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
	fi
fi
printReport