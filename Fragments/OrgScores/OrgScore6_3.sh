#!/bin/zsh
# shellcheck shell=bash

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source "${projectfolder}/Header.sh"

CISLevel="1"
audit="6.3 Ensure Automatic Opening of Safe Files in Safari Is Disabled (Automated)"
orgScore="OrgScore6_3"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.Safari > AutoOpenSafeDownloads=false"

	appidentifier="com.apple.Safari"
	value="AutoOpenSafeDownloads"
	prefValue=$(getPrefValuerunAsUser "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManagedrunAsUser "${appidentifier}" "${value}")
	comment="Automatic run of safe files in Safari: Disabled"
	if [[ "${prefIsManaged}" == "true" && "${prefValue}" == "false" ]]; then
		result="Passed"
	else
		if [[ "${prefValue}" == "false" ]]; then
			result="Passed"
		else
			result="Failed"
			comment="Automatic run of safe files in Safari: Enabled"
		fi
	fi
fi
printReport