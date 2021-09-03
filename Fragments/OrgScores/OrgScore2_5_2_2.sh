#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit="2.5.2.2 Enable Firewall (Automated)"
orgScore="OrgScore2_5_2_2"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.security.firewall > EnableFirewall=true"

	appidentifier="com.apple.security.firewall"
	value="EnableFirewall"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Firewall: Enabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValue}" == "True" ]]; then
		result="Passed"
	else
		if [[ "${prefValue}" == "1" ]]; then
			result="Passed"
		else
			result="Failed"
			comment="Firewall: Disabled"
		fi
	fi
fi
printReport