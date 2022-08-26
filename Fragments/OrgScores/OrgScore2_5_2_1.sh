#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit="2.5.2.1 Ensure Gatekeeper is Enabled (Automated)"
orgScore="OrgScore2_5_2_1"
emptyVariables
method="Profile"
remediate="Configuration profile - payload > com.apple.systempolicy.control > EnableAssessment=true "
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	checkGatekeeperStatus=$(/usr/sbin/spctl --status | /usr/bin/grep -c "assessments enabled")
	if [[ "${checkGatekeeperStatus}" == "1" ]]; then
		result="Passed"
		comment="Gatekeeper Enabled"
	else
		result="Failed"
		comment="Gatekeeper Not Enabled"
	fi
fi
printReport