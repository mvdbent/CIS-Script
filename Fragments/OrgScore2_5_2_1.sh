#!/bin/zsh

projectfolder=$(dirname "${0:A}")

source ${projectfolder}/Header.sh

CISLevel="1"
audit="2.5.2.1 Enable Gatekeeper (Automated)"
orgScore="OrgScore2_5_2_1"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.systempolicy.control > EnableAssessment=true"

	appidentifier="com.apple.systempolicy.control"
	value="EnableAssessment"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Gatekeeper: Enabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValue}" == "1" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
	else
		if [[ "${prefValue}" == "1" ]]; then
			countPassed=$((countPassed + 1))
			result="Passed"
		else
			gatekeeperEnabled=$(spctl --status 2>&1 | grep -c "assessments enabled")
			if [[ "$gatekeeperEnabled" = "1" ]]; then
				countPassed=$((countPassed + 1))
				result="Passed"
			else
				countFailed=$((countFailed + 1))
				result="Failed"
				comment="Gatekeeper: Disabled"
			fi
		fi
	fi
fi
printReport