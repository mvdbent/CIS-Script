#!/bin/zsh

projectfolder=$(dirname "${0:A}")

source ${projectfolder}/Header.sh

CISLevel="1"
audit="6.1.1 Display login window as name and password (Automated)"
orgScore="OrgScore6_1_1"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.loginwindow > SHOWFULLNAME=true"

	appidentifier="com.apple.loginwindow"
	value="SHOWFULLNAME"
	prefValueAsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Display login window as name and password: Enabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValueAsUser}" == "True" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
	else
		if [[ "${prefValueAsUser}" == "True" ]]
		then
			countPassed=$((countPassed + 1))
			result="Passed"
		else
			countFailed=$((countFailed + 1))
			result="Failed"
			comment="Display login window as name and password: Disabled"
		fi
	fi
fi
printReport