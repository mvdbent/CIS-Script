#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="2"
audit="2.6.3 iCloud Drive (Manual)"
orgScore="OrgScore2_6_3"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.applicationaccess > allowCloudDocumentSync=false"

	appidentifier="com.apple.applicationaccess"
	value="allowCloudDocumentSync"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="iCloud Drive: Disabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValue}" == "False" ]]; then
		result="Passed"
	else
		if [[ "${prefValue}" == "False" ]]; then
			result="Passed"
	else
			result="Failed"
			comment="iCloud Drive: Enabled"
		fi
	fi
fi
printReport