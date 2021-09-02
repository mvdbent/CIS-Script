#!/bin/zsh

projectfolder=$(dirname "${0:A}")

source ${projectfolder}/Header.sh

CISLevel="1"
audit="1.6 Enable macOS update installs (Automated)"
orgScore="OrgScore1_6"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.SoftwareUpdate > AutomaticallyInstallMacOSUpdates=true)"

	appidentifier="com.apple.SoftwareUpdate"
	value="AutomaticallyInstallMacOSUpdates"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="macOS update installs: Enabled"
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
			comment="macOS update installs: Disabled"
		fi
	fi
fi
printReport