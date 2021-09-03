#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit="5.11 Require an administrator password to access system-wide preferences (Automated)"
orgScore="OrgScore5_11"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo security authorizationdb read system.preferences > /tmp/system.preferences.plist && sudo defaults write /tmp/system.preferences.plist shared -bool false && sudo security authorizationdb write system.preferences < /tmp/system.preferences.plist"

	adminSysPrefs="$(security authorizationdb read system.preferences 2> /dev/null | grep -A 1 "<key>shared</key>" | grep -c "<false/>")"
	if [[ "${adminSysPrefs}" == "1" ]]; then
		result="Passed"
		comment="Require an administrator password to access system-wide preferences: Enabled"
	else 
		result="Failed"
		comment="Require an administrator password to access system-wide preferences: Disabled"
	fi
fi
printReport