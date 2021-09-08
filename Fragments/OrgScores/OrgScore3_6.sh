#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

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
		result="Passed"
		comment="Firewall logging: Enabled"
	else 
		result="Failed"
		comment="Firewall logging: Disabled"
		# Remediation
		if [[ "${remediateResult}" == "enabled" ]]; then
			/usr/libexec/ApplicationFirewall/socketfilterfw --setloggingmode on
			# re-check
			FWlog=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getloggingmode | grep -c "Log mode is on")
			printCLIResult=$(systemsetup -getnetworktimeserver)
			if [[ "$FWlog" = "1" ]]; then
				result="Passed After Remdiation"
				comment="Firewall logging: Enabled"
			else
				result="Failed After Remediation"
				comment="Firewall logging: Disabled"
			fi
		fi	
	fi
fi
printReport