#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit="5.7 Ensure Automatic Login Is Disabled (Automated)"
orgScore="OrgScore5_7"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.loginwindow> DisableAutoLoginClient=true"

	appidentifier="com.apple.loginwindow"
	value="DisableAutoLoginClient"
	prefValueAsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Automatic login: Disabled"
	if [[ "${prefIsManaged}" == "true" && "${prefValueAsUser}" == "true" ]]; then
		result="Passed"
	else
		if [[ "${prefValueAsUser}" == "true" ]]; then
			result="Passed"
		else
			automaticLogin=$(defaults read /Library/Preferences/com.apple.loginwindow | grep -c "autoLoginUser")
			if [[ "${automaticLogin}" == "0" ]]; then
				result="Passed"
			else
				result="Failed"
				comment="Automatic login: Enabled"
			fi
		fi
	fi
fi
printReport