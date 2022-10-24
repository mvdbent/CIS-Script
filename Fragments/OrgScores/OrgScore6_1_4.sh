#!/bin/zsh
# shellcheck shell=bash

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source "${projectfolder}/Header.sh"

CISLevel="1"
audit="6.1.4 Ensure Guest Access to Shared Folders Is Disabled (Automated)"
orgScore="OrgScore6_1_4"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.smb.server AllowGuestAccess=false"
	
	appidentifier="com.apple.smb.server"
	value="AllowGuestAccess"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Allow guests to connect to shared folders: Disabled"
	if [[ "${prefIsManaged}" == "true" && "${prefValue}" == "false" ]]; then
		result="Passed"
	else
		if [[ "${prefValue}" == "false" ]]; then
			result="Passed"
		else
			result="Failed"
			comment="Allow guests to connect to shared folders: Enabled"
		fi
	fi
fi
printReport