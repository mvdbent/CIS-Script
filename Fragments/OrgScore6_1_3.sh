#!/bin/zsh

projectfolder=$(dirname "${0:A}")

source ${projectfolder}/Header.sh

CISLevel="1"
audit="6.1.3 Disable guest account login (Automated)"
orgScore="OrgScore6_1_3"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.MCX > DisableGuestAccount=True"

	appidentifier="com.apple.MCX"
	value="DisableGuestAccount"
	prefValue=$(getPrefValuerunAsUser "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Guest account: Disabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValue}" == "True" ]]; then
		result="Passed"
	else
		if [[ "${prefValue}" == "True" ]]
		then
			result="Passed"
		else
			result="Failed"
			comment="Guest account: Enabled"
		fi
	fi
fi
printReport