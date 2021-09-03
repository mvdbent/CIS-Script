#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit="2.3.1 Set an inactivity interval of 20 minutes or less for the screen saver (Automated)"
orgScore="OrgScore2_3_1"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.screensaver > idleTime=1200"

	appidentifier="com.apple.screensaver"
	value="idleTime"
	prefValueAsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Inactivity interval for the screen saver: ${prefValueAsUser}"
	if [[ "${prefIsManaged}" == "True" && "${prefValueAsUser}" -le "1200" ]]; then
		result="Passed"
	else
		if [[ "${prefValueAsUser}" -le "1200" && "${prefValueAsUser}" != "" ]]; then
			result="Passed"
		else
			result="Failed"
			comment="Inactivity interval for the screen saver: ${prefValueAsUser}"
		fi
	fi
fi
printReport