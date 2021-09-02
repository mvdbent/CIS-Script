#!/bin/zsh

projectfolder=$(dirname "${0:A}")

source ${projectfolder}/Header.sh

CISLevel="1"
audit="1.3 Enable Download new updates when available (Automated)"
orgScore="OrgScore1_3"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.SoftwareUpdate > AutomaticDownload=true"

	appidentifier="com.apple.SoftwareUpdate"
	value="AutomaticDownload"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Download new updates when available: Enabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValue}" == "True" ]]; then
		countPassed=$((countPassed + 1))		
		result="Passed"
	else
		if [[ "${prefValue}" == "True" ]]; then
			countPassed=$((countPassed + 1))		
			result="Passed"
		else
			countFailed=$((countFailed + 1))
			result="Failed"
			comment="Download new updates when available: Disabled"
		fi
	fi
fi
printReport