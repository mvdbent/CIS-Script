#!/bin/zsh

projectfolder=$(dirname "${0:A}")

source ${projectfolder}/Header.sh

CISLevel="1"
audit="5.12 Ensure an administrator account cannot login to another user's active and locked session (Automated)"
orgScore="OrgScore5_12"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo security authorizationdb write system.login.screensaver 'use-login-window-ui'"

	screensaverRules="$(security authorizationdb read system.login.screensaver 2>&1 | grep -c 'use-login-window-ui')"
	if [[ "${screensaverRules}" == "1" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="Ability to login to another user's active and locked session: Disabled"
	else 
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="Ability to login to another user's active and locked session: Enabled"
	fi
fi
printReport