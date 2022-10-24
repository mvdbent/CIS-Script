#!/bin/zsh
# shellcheck shell=bash

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source "${projectfolder}/Header.sh"

CISLevel="2"
audit="2.4.10 Ensure Content Caching Is Disabled (Automated)"
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
	if [[ "${prefIsManaged}" == "true" && "${prefValue}" == "false" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
	else
		if [[ "${prefValue}" == "false" ]]; then
			result="Passed"
		else
			contentCacheStatus=$(AssetCacheManagerUtil status 2>&1 | grep -c "Activated: true")
			if [[ "${contentCacheStatus}" == 0 ]]; then
				result="Passed"
			else
				result="Failed"
				comment="Content Caching: Enabled"
			fi
		fi
	fi
fi
printReport