#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit="2.5.7 Limit Ad tracking and personalized Ads (Automated)"
orgScore="OrgScore2_5_7"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.AdLib > allowApplePersonalizedAdvertising=false"

	appidentifier="com.apple.AdLib"
	value="allowApplePersonalizedAdvertising"
	prefValueAsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Limited Ad Tracking: Disabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValueAsUser}" == "False" ]]; then
		result="Passed"
	else
		if [[ "${prefValueAsUser}" == "False" ]]; then
			result="Passed"
		else
			result="Failed"
			comment="Limited Ad Tracking: Enabled"
		fi
	fi
fi
printReport