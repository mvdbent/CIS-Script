#!/bin/zsh
# shellcheck shell=bash

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source "${projectfolder}/Header.sh"

CISLevel="2"
audit="2.7.1 Ensure Backup Up Automatically is Enabled (Automated)"
orgScore="OrgScore2_7_1"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.TimeMachine > AutoBackup=true"

	appidentifier="com.apple.TimeMachine"
	value="AutoBackup"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Backup Up: Enabled"
	if [[ "${prefIsManaged}" == "true" && "${prefValue}" == "true" ]]; then
		result="Passed"
	else
		if [[ "${prefValue}" == "true" ]]; then
			result="Passed"
		else
			result="Failed"
			comment="Backup Up: Disabled"
		fi
	fi
fi
printReport