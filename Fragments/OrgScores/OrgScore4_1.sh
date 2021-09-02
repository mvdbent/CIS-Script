#!/bin/zsh

projectfolder=$(dirname "${0:A}")

source ${projectfolder}/Header.sh

CISLevel="2"
audit="4.1 Disable Bonjour advertising service (Automated)"
orgScore="OrgScore4_1"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.mDNSResponder > NoMulticastAdvertisements=true"

	appidentifier="com.apple.mDNSResponder"
	value="NoMulticastAdvertisements"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Bonjour advertising service: Disable"
	if [[ "${prefIsManaged}" == "True" && "${prefValue}" == "True" ]]; then
		result="Passed"
	else
		if [[ "${prefValue}" == "True" ]]; then
			result="Passed"
		else
			result="Failed"
			comment="Bonjour advertising service: Enabled"
		fi
	fi
fi
printReport