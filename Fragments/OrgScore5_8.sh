#!/bin/zsh

projectfolder=$(dirname "${0:A}")

source ${projectfolder}/Header.sh

CISLevel="1"
audit="5.8 Disable automatic login (Automated)"
orgScore="OrgScore5_8"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.loginwindow> DisableFDEAutoLogin=true"

	appidentifier="com.apple.loginwindow"
	value="DisableFDEAutoLogin"
	prefValueAsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Automatic login: Disabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValueAsUser}" == "True" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
	else
		if [[ "${prefValueAsUser}" == "True" ]]; then
			countPassed=$((countPassed + 1))
			result="Passed"
		else
			automaticLogin=$(defaults read /Library/Preferences/com.apple.loginwindow | grep -c "autoLoginUser")
			if [[ "${automaticLogin}" == "0" ]]; then
				countPassed=$((countPassed + 1))
				result="Passed"
			else
				countFailed=$((countFailed + 1))
				result="Failed"
				comment="Automatic login: Enabled"
			fi
		fi
	fi
fi
printReport