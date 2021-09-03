#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit="3.1 Enable security auditing (Automated)"
orgScore="OrgScore3_1"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.auditd.plist"

	auditdEnabled=$(launchctl list 2>&1 | grep -c auditd)
	if [[ "${auditdEnabled}" -gt "0" ]]; then
		result="Passed"
		comment="Security auditing: Enabled"
	else 
		result="Failed"
		comment="Security auditing: Disabled"
	fi
fi
printReport