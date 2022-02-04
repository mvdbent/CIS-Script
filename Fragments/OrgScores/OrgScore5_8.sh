#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit="5.8 Ensure a Password is Required to Wake the Computer From Sleep or Screen Saver Is Enabled (Automated)"
orgScore="OrgScore5_8"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.screensaver > askForPassword=true askForPasswordDelay=0"

n	appidentifier="com.apple.screensaver"
	value="askForPassword"
	value2="askForPasswordDelay"
	prefValueAsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value}")
	prefValueAsUser2=$(getPrefValuerunAsUser "${appidentifier}" "${value2}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Require a password to wake the computer from sleep or screen saver: Enabled"
	if [[ "${prefIsManaged}" == "true" && "${prefValueAsUser}" == "true" && "${prefValueAsUser2}" == "0" ]]; then
		result="Passed"
	else
		if [[ "${prefValueAsUser}" == "true" && "${prefValueAsUser2}" == "0" ]]; then
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