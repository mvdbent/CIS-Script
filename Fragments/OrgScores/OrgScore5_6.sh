#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit="5.6 Ensure the 'root' Account Is Disabled (Automated)"
orgScore="OrgScore5_6"
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
		result="Passed"
		comment="root user account: Disabled"
	else 
		result="Failed"
		comment="root user account: Enabled"
		# Remediation
		if [[ "${remediateResult}" == "enabled" ]]; then
			dscl . -create /Users/root UserShell /usr/bin/false
			# re-check
			rootEnabled="$(dscl . -read /Users/root AuthenticationAuthority 2>&1 | grep -c "No such key")"
			rootEnabledRemediate="$(dscl . -read /Users/root UserShell 2>&1 | grep -c "/usr/bin/false")"
			if [[ "${rootEnabled}" == "1" || "${rootEnabledRemediate}" == "1" ]]; then
				result="Passed After Remediation"
				comment="root user account: Disabled"
			else
				result="Failed After Remediation"
			fi
		fi
	fi
fi
printReport