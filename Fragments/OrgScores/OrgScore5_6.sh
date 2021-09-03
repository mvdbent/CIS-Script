#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="2"
audit="5.6 Ensure login keychain is locked when the computer sleeps (Manual)"
orgScore="OrgScore5_6"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo -u <username> security set-keychain-settings -l /Users/<username>/Library/Keychains/login.keychain"

	lockSleep="$(security show-keychain-info /Users/"${currentUser}"/Library/Keychains/login.keychain 2>&1 | grep -c "lock-on-sleep")"
	if [[ "${lockSleep}" == "1" ]]; then
		result="Passed"
		comment="Login keychain is locked when the computer sleeps: Enabled"
	else 
		result="Failed"
		comment="Login keychain is locked when the computer sleeps: Disabled"
	fi
fi
printReport