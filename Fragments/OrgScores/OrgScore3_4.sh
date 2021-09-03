#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit="3.4 Ensure security auditing retention (Automated)"
orgScore="OrgScore3_4"
emptyVariables
# Verify organizational score
runAudit
# If organizational scorse is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > add 'expire-after:60d OR 1G' to /etc/security/audit_control"

	auditRetention="$(grep -c expire-after /etc/security/audit_control)"	
	if [[  "${auditRetention}" == "1" ]]; then
		result="Passed"
		comment="Security auditing retention: Configured"
	else 
		result="Failed"
		comment="Security auditing retention: Unconfigured"
	fi
fi
printReport