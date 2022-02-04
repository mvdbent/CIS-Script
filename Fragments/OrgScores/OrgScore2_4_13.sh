#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit="2.4.13 Ensure AirPlay Receiver Is Disabled (Automated)"
orgScore="OrgScore2_4_13"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.controlcenter > AirplayRecieverEnabled=false"

	appidentifier="com.apple.controlcenter"
	value="AirplayRecieverEnabled"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Airplay Receiver: Disabled"
	if [[ "$osVersion" != "12."* ]]; then
	comment="Benchmark not compactible with OS Version" 
	else
		if [[ "${prefIsManaged}" == "true" && "${prefValue}" == "false" ]]; then
		result="Passed"
		else
			if [[ "${prefValue}" == "false" ]]; then
			result="Passed"
			else
			result="Failed"
			comment="Airplay Receiver: Enabled"
			fi
		fi
	fi
fi
printReport