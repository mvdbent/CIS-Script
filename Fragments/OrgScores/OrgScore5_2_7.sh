#!/bin/zsh
# shellcheck shell=bash

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source "${projectfolder}/Header.sh"

CISLevel="1"
audit="5.2.7 Ensure Password Age Is Configured (Automated)"
orgScore="OrgScore5_2_7"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.mobiledevice.passwordpolicy > maxPINAgeInDays=<365> 'must be lower than or equal to 365'"

	appidentifier="com.apple.mobiledevice.passwordpolicy"
	value="maxPINAgeInDays"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Password Age: Configured"
	if [[ "${prefIsManaged}" == "true" && ${prefValue} -lt 365 ]]; then
		result="Passed"
	else
		if [[ ${prefValue} -lt 365 ]]; then
			result="Passed"
		else
			result="Failed"
			comment="Password Age: not Configured"
		fi
	fi
fi
printReport