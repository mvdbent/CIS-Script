#!/bin/zsh

projectfolder=$(dirname "${0:A}")

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
	
	keyTimeout="$(security show-keychain-info /Users/"${currentUser}"/Library/Keychains/login.keychain 2>&1 | grep -c "no-timeout")"
	if [[ "${keyTimeout}" == "1" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="Automatically lock the login keychain for inactivity: Enabled"
	else 
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="Automatically lock the login keychain for inactivity: Disabled"
	fi
fi
printReport