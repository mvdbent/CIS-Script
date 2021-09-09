#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit='6.1.2 Disable "Show password hints" (Automated)'
orgScore="OrgScore6_1_2"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.loginwindow > RetriesUntilHint=0"

	appidentifier="com.apple.loginwindow"
	value="RetriesUntilHint"
	prefValueAsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Show password hints: Disabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValueAsUser}" == "0" ]]; then
		result="Passed"
	else
		if [[ "${prefValueAsUser}" == "0" ]]; then
			result="Passed"
		else
			result="Failed"
			comment="Show password hints: Enabled"
		fi
	fi
fi
printReport