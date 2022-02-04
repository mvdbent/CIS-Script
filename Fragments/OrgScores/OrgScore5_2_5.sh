#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="2"
audit="5.2.5 Ensure Complex Password Must Contain Special Character Is Configured (Manual)"
orgScore="OrgScore5_2_5"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.mobiledevice.passwordpolicy > minComplexChars=<1>"

	appidentifier="com.apple.mobiledevice.passwordpolicy"
	value="minComplexChars"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Password Special Character: Configured"
	if [[ "${prefIsManaged}" == "true" && "${prefValue}" == "1" ]]; then
		result="Passed"
	else
		if [[ "${prefValue}" == "1" ]]; then
			result="Passed"
		else
			result="Failed"
			comment="Password Special Character: not Configured"
		fi
	fi
fi
printReport