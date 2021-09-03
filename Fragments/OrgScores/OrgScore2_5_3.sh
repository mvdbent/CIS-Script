#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit="2.5.3 Review Application Firewall Rules (Manual)"
orgScore="OrgScore2_5_3"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.security.firewall > Applications > Array > BundleID=com.apple.app > Allowed=false"

	appsInbound=$(/usr/libexec/ApplicationFirewall/socketfilterfw --listapps | grep ALF | awk '{print $7}')
	if [[ "${appsInbound}" -le "10" || -z "${appsInbound}" ]]; then
		result="Passed"
		comment="Application Firewall Rules: ${appsInbound} Application Managed"
	else 
		result="Failed"
		comment="Application Firewall Rules: ${appsInbound} Application Managed"
	fi
fi
printReport