#!/bin/zsh

projectfolder=$(dirname "${0:A}")

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

	controlAccess=$(grep '^dir' /etc/security/audit_control | awk -F: '{print $2}')
	accessCheck=$(find "${controlAccess}" | awk '{s+=$3} END {print s}')
	if [[ "${accessCheck}" == "0" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="Control access to audit records: Correct ownership"
	else 
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="Control access to audit records: Incorrect ownership"
	fi
fi
printReport