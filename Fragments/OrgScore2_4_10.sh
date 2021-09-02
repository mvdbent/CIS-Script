#!/bin/zsh

projectfolder=$(dirname "${0:A}")

source ${projectfolder}/Header.sh

CISLevel="2"
audit="2.4.10 Disable Content Caching (Automated)"
orgScore="OrgScore2_4_10"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.applicationaccess > allowContentCaching=false"

	appidentifier="com.apple.applicationaccess"
	value="allowContentCaching"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Content Caching: Disabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValue}" == "False" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
	else
		if [[ "${prefValue}" == "False" ]]; then
			countPassed=$((countPassed + 1))
			result="Passed"
		else
			contentCacheStatus=$(AssetCacheManagerUtil status 2>&1 | grep -c "Activated: true")
			if [[ "${contentCacheStatus}" == 0 ]]; then
				countPassed=$((countPassed + 1))
				result="Passed"
			else
				countFailed=$((countFailed + 1))
				result="Failed"
				comment="Content Caching: Enabled"
			fi
		fi
	fi
fi
printReport