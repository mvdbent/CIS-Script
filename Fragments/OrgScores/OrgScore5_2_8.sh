#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit="5.2.8 Ensure Password History Is Configured (Automated)"
orgScore="OrgScore5_2_8"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.mobiledevice.passwordpolicy > pinHistory=<15> 'must be higer than or equal to 15'"

	appidentifier="com.apple.mobiledevice.passwordpolicy"
	value="pinHistory"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Password History: Configured"
	if [[ "${prefIsManaged}" == "true" && "${prefValue}" > "15" ]]; then
		result="Passed"
	else
		if [[ "${prefValue}" > "15" ]]; then
			result="Passed"
		else
			result="Failed"
			comment="Password History: not Configured"
		fi
	fi
fi
printReport