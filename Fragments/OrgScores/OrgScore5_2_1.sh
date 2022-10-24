#!/bin/zsh
# shellcheck shell=bash

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source "${projectfolder}/Header.sh"

CISLevel="1"
audit="5.2.1 Ensure Password Account Lockout Threshold Is Configured (Automated)"
orgScore="OrgScore5_2_1"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.mobiledevice.passwordpolicy > maxFailedAttempts=5"

	appidentifier="com.apple.mobiledevice.passwordpolicy"
	value="maxFailedAttempts"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Password Account Lockout Threshold: Configured"
	if [[ "${prefIsManaged}" == "true" && "${prefValue}" == "5" ]]; then
		result="Passed"
	else
		if [[ "${prefValue}" == "5" ]]; then
			result="Passed"
		else
			result="Failed"
			comment="Password Account Lockout Threshold: not Configured"
		fi
	fi
fi
printReport