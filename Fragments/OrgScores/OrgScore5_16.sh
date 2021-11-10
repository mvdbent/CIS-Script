#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="2"
audit="5.16 Disable Fast User Switching (Manual)"
orgScore="OrgScore5_16"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > .GlobalPreferences > MultipleSessionEnabled=false"

	appidentifier=".GlobalPreferences"
	value="MultipleSessionEnabled"
	prefValueAsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Fast User Switching: Disabled"
	if [[ "${prefIsManaged}" == "true" && "${prefValueAsUser}" == "false" ]]; then
		result="Passed"
	else
		if [[ "${prefValue}" == "false" ]]; then
			result="Passed"
		else
			result="Failed"
			comment="Fast User Switching: Enabled"
		fi
	fi
fi
printReport