#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit="5.2.2 Ensure Password Minimum Length Is Configured (Automated)"
orgScore="OrgScore5_2_2"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.mobiledevice.passwordpolicy > minLength=15"

	appidentifier="com.apple.mobiledevice.passwordpolicy"
	value="minLength"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Password Minimum Length: Configured"
	if [[ "${prefIsManaged}" == "true" && "${prefValue}" > "15" ]]; then
		result="Passed"
	else
		if [[ "${prefValue}" > "15" ]]; then
			result="Passed"
		else
			result="Failed"
			comment="Password Minimum Length: not Configured"
		fi
	fi
fi
printReport