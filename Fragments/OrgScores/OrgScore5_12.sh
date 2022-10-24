#!/bin/zsh
# shellcheck shell=bash

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source "${projectfolder}/Header.sh"

CISLevel="1"
audit="5.12 Ensure a Custom Message for the Login Screen Is Enabled (Automated)"
orgScore="OrgScore5_12"
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
	if [[ "${prefIsManaged}" == "true" && "${prefValueAsUser}" != "" ]]; then
		result="Passed"
	else
		if [[ "${prefValueAsUser}" != "" ]]; then
			result="Passed"
		else
			result="Failed"
			comment="Custom message for the Login Screen: Disabled"
		fi
	fi
fi
printReport