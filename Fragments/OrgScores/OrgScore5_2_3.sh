#!/bin/zsh
# shellcheck shell=bash

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source "${projectfolder}/Header.sh"

CISLevel="2"
audit="5.2.3 Ensure Complex Password Must Contain Alphabetic Characters Is Configured (Manual)"
orgScore="OrgScore5_2_3"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.mobiledevice.passwordpolicy > requireAlphanumeric=true"

	appidentifier="com.apple.mobiledevice.passwordpolicy"
	value="requireAlphanumeric"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Password Alphabetic Characters: Configured"
	if [[ "${prefIsManaged}" == "true" && "${prefValue}" == "true" ]]; then
		result="Passed"
	else
		if [[ "${prefValue}" == "true" ]]; then
			result="Passed"
		else
			result="Failed"
			comment="Password Alphabetic Characters: not Configured"
		fi
	fi
fi
printReport