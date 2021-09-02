#!/bin/zsh

projectfolder=$(dirname "${0:A}")

source ${projectfolder}/Header.sh

CISLevel="1"
audit="3.6 Ensure Firewall is configured to log (Automated)"
orgScore="OrgScore3_6"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setloggingmode on"

	FWlog=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getloggingmode | grep -c "Log mode is on")
	if [[ "$FWlog" = "1" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="Firewall logging: Enabled"
	else 
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="Firewall logging: Disabled"

		# Remediation
		/usr/libexec/ApplicationFirewall/socketfilterfw --setloggingmode on
		countRemediated=$((countRemediated + 1))
		# re-check
		FWlog=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getloggingmode | grep -c "Log mode is on")
		printCLIResult=$(systemsetup -getnetworktimeserver)
		if [[ "$FWlog" = "1" ]]; then
			Remediated
			result="Passed After Remdiation"
			comment="Firewall logging: Enabled"
		else
			countFailedAfterRemediation=$((countFailedAfterRemediation + 1))
			result="FailedAfterRemediation"
			comment="Firewall logging: Disabled"
		fi
	fi
fi
printReport