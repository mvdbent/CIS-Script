#!/bin/zsh
# shellcheck shell=bash

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source "${projectfolder}/Header.sh"

CISLevel="1"
audit="2.5.2.2 Ensure Firewall Is Enabled (Automated)"
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
	if [[ "${prefIsManaged}" == "true" && "${prefValue}" == "true" ]]; then
		result="Passed"
	else
		if [[ "${prefValue}" == "1" ]]; then
			result="Passed"
		else	
			firewallState=$(defaults read /Library/Preferences/com.apple.alf globalstate 2>&1)
			if [[ "$firewallState" = "1" ]]; then
				result="Passed"
			else
				result="Failed"
				comment="Firewall: Disabled"
			fi
		fi
	fi
fi
printReport