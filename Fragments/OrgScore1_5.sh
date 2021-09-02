#!/bin/zsh

projectfolder=$(dirname "${0:A}")

source ${projectfolder}/Header.sh

CISLevel="1"
audit="1.5 Enable system data files and security updates install (Automated)"
orgScore="OrgScore1_5"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.SoftwareUpdate > ConfigDataInstall=true - CriticalUpdateInstall=true "

	appidentifier="com.apple.SoftwareUpdate"
	value="ConfigDataInstall"
	value2="CriticalUpdateInstall"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefValue2=$(getPrefValue "${appidentifier}" "${value2}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="System data files and security update installs: Enabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValue}" == "True" && "${prefValue2}" == "True" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
	else
		if [[ "${prefValue}" == "True" && "${prefValue2}" == "True" ]]; then
			countPassed=$((countPassed + 1))
			result="Passed"
		else
			countFailed=$((countFailed + 1))
			result="Failed"
			comment="System data files and security update installs: Disabled"
		fi
	fi
fi
printReport