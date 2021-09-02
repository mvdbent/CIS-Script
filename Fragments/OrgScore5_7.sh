#!/bin/zsh

projectfolder=$(dirname "${0:A}")

source ${projectfolder}/Header.sh

CISLevel="1"
audit='5.7 Do not enable the "root" account (Automated)'
orgScore="OrgScore5_7"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo dscl . -create /Users/root UserShell /usr/bin/false"

	rootEnabled="$(dscl . -read /Users/root AuthenticationAuthority 2>&1 | grep -c "No such key")"
	rootEnabledRemediate="$(dscl . -read /Users/root UserShell 2>&1 | grep -c "/usr/bin/false")"
	if [[ "${rootEnabled}" == "1" || "${rootEnabledRemediate}" == "1" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="root user account: Disabled"
	else 
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="root user account: Enabled"
	fi
fi
printReport