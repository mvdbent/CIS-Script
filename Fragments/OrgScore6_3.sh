#!/bin/zsh

projectfolder=$(dirname "${0:A}")

source ${projectfolder}/Header.sh

CISLevel="1"
audit="6.3 Disable the automatic run of safe files in Safari (Automated)"
orgScore="OrgScore6_3"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.Safari > AutoOpenSafeDownloads=false"

	appidentifier="com.apple.Safari"
	value="AutoOpenSafeDownloads"
	prefValue=$(getPrefValuerunAsUser "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManagedrunAsUser "${appidentifier}" "${value}")
	comment="Automatic run of safe files in Safari: Disabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValue}" == "False" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
	else
		if [[ "${prefValue}" == "False" ]]
		then
			countPassed=$((countPassed + 1))
			result="Passed"
		else
			countFailed=$((countFailed + 1))
			result="Failed"
			comment="Automatic run of safe files in Safari: Enabled"
		fi
	fi
fi
printReport