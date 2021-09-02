#!/bin/zsh

projectfolder=$(dirname "${0:A}")

source ${projectfolder}/Header.sh

CISLevel="1"
audit="6.2 Turn on filename extensions (Automated)"
orgScore="OrgScore6_2"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > .GlobalPreferences > AppleShowAllExtensions=true"

	appidentifier="com.apple.GlobalPreferences"
	value="AppleShowAllExtensions"
	prefValue=$(getPrefValuerunAsUser "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Show all Filename extensions: Enabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValue}" == "True" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
	else
		if [[ "${prefValue}" == "True" ]]
		then
			countPassed=$((countPassed + 1))
			result="Passed"
		else
			countFailed=$((countFailed + 1))
			result="Failed"
			comment="Show all Filename extensions: Disabled"
		fi
	fi
fi
printReport