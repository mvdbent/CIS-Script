#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="2"
audit="5.4 Automatically lock the login keychain for inactivity (Manual)"
orgScore="OrgScore5_4"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo -u <username> security set-keychain-settings -t 21600 /Users/<username>/Library/Keychains/login.keychain"
	
	keyTimeout="$(security show-keychain-info /Users/"${currentUser}"/Library/Keychains/login.keychain 2>&1 | grep -c "timeout=21600s")"
	if [[ "${keyTimeout}" == "1" ]]; then
		result="Passed"
		comment="Automatically lock the login keychain for inactivity: Enabled"
	else 
		result="Failed"
		comment="Automatically lock the login keychain for inactivity: Disabled"
		# Remediation
		if [[ "${remediateResult}" == "enabled" ]]; then
			security set-keychain-settings -u -t 21600s /Users/"${currentUser}"/Library/Keychains/login.keychain
			# re-check
			keyTimeout="$(security show-keychain-info /Users/"${currentUser}"/Library/Keychains/login.keychain 2>&1 | grep -c "timeout=21600s")"
			if [[ "${keyTimeout}" == "1" ]]; then
				result="Passed After Remediation"
				comment="Automatically lock the login keychain for inactivity: Enabled"
			else
				result="Failed After Remediation"
			fi
		fi
	fi
fi
printReport