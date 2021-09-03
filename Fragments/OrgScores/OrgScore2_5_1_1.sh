#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit="2.5.1.1 Enable FileVault (Automated)"
orgScore="OrgScore2_5_1_1"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.MCX.FileVault2 > Enable=On"

	appidentifier="com.apple.MCX.FileVault2"
	value="Enable"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="FileVault: Enabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValue}" == "On" ]]; then
		result="Passed"
	else
		if [[ "${prefValue}" == "On" ]]; then
			result="Passed"
		else
			filevaultEnabled=$(fdesetup status | grep -c "FileVault is On.")
			if [[ "$filevaultEnabled" == "1" ]]; then
				result="Passed"
			else
				result="Failed"
				comment="FileVault: Disabled"
			fi
		fi
	fi
fi
printReport