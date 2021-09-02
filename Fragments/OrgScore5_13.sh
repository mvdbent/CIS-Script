#!/bin/zsh

projectfolder=$(dirname "${0:A}")

source ${projectfolder}/Header.sh

CISLevel="1"
audit="5.13 Create a custom message for the Login Screen (Automated)"
orgScore="OrgScore5_13"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.loginwindow > LoginwindowText='message'"

	appidentifier="com.apple.loginwindow"
	value="LoginwindowText"
	prefValueAsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Custom message for the Login Screen: Enabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValueAsUser}" != "" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
	else
		if [[ "${prefValueAsUser}" != "" ]]
		then
			countPassed=$((countPassed + 1))
			result="Passed"
		else
			countFailed=$((countFailed + 1))
			result="Failed"
			comment="Custom message for the Login Screen: Disabled"
		fi
	fi
fi
printReport