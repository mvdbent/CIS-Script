#!/bin/zsh

projectfolder=$(dirname "${0:A}")

source ${projectfolder}/Header.sh

CISLevel="1"
audit="5.9 Require a password to wake the computer from sleep or screen saver (Manual)"
orgScore="OrgScore5_9"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.screensaver > askForPassword=true"

	appidentifier="com.apple.screensaver"
	value="askForPassword"
	prefValueAsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Require a password to wake the computer from sleep or screen saver: Enabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValueAsUser}" == "True" ]]; then
		result="Passed"
	else
		if [[ "${prefValueAsUser}" == "True" ]]; then
			result="Passed"
		else
			passwordWake=$(defaults read /Users/"$currentUser"/Library/Preferences/com.apple.screensaver | grep -c "askForPassword")
			if [[ "${passwordWake}" == "0" ]]; then
				result="Passed"
			else
				result="Failed"
				comment="Require a password to wake the computer from sleep or screen saver: Disabled"
			fi
		fi
	fi
fi
printReport