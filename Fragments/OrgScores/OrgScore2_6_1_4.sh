#!/bin/zsh
# shellcheck shell=bash

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source "${projectfolder}/Header.sh"

CISLevel="2"
audit="2.6.1.4 Ensure iCloud Drive Document and Desktop Sync is Disabled (Automated)"
orgScore="OrgScore2_6_1_4"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.applicationaccess > allowCloudDesktopAndDocuments=false"

	appidentifier="com.apple.applicationaccess"
	value="allowCloudDesktopAndDocuments"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="iCloud Drive Document and Desktop sync: Disabled"
	if [[ "${prefIsManaged}" == "true" && "${prefValue}" == "false" ]]; then
		result="Passed"
	else
		if [[ "${prefValue}" == "false" ]]; then
			result="Passed"
		else
			result="Failed"
			comment="iCloud Drive Document and Desktop sync: Enabled"
		fi
	fi
fi
printReport