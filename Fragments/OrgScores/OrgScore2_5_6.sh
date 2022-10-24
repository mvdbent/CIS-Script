#!/bin/zsh
# shellcheck shell=bash

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source "${projectfolder}/Header.sh"

CISLevel="1"
audit="2.5.6 Ensure Limit Ad Tracking Is Enabled (Automated)"
orgScore="OrgScore2_5_6"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.AdLib > allowApplePersonalizedAdvertising=false"

	appidentifier="com.apple.AdLib"
	value="allowApplePersonalizedAdvertising"
	prefValueAsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Limited Ad Tracking: Disabled"
	if [[ "${prefIsManaged}" == "true" && "${prefValueAsUser}" == "false" ]]; then
		result="Passed"
	else
		if [[ "${prefValueAsUser}" == "false" ]]; then
			result="Passed"
		else
			result="Failed"
			comment="Limited Ad Tracking: Enabled"
		fi
	fi
fi
printReport