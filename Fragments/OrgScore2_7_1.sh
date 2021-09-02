#!/bin/zsh

projectfolder=$(dirname "${0:A}")

source ${projectfolder}/Header.sh

CISLevel="2"
audit="2.7.1 Time Machine Auto-Backup (Automated)"
orgScore="OrgScore2_7_1"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo defaults write /Library/Preferences/com.apple.TimeMachine.plist AutoBackup 1"

	timeMachineAuto=$(defaults read /Library/Preferences/com.apple.TimeMachine.plist AutoBackup 2>&1)
	if [[ "$timeMachineAuto" != "0" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="Time Machine Auto-Backup: Enabled"
	else 
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="Time Machine Auto-Backup: Disabled"
	fi
fi
printReport