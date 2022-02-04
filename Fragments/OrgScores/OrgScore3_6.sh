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
	if [[ "$osVersion" == "12."* ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.security.firewall > EnableLogging=true LoggingOption=detail"

	appidentifier="com.apple.security.firewall"
	value="EnableLogging"
	value2="LoggingOption"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefValue2=$(getPrefValue "${appidentifier}" "${value2}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Firewall logging: Enabled"
		if [[ "${prefIsManaged}" == "true" && "${prefValue}" == "true" && "${prefValue2}" == "detail" ]]; then
			result="Passed"
		else
			if [[ "${prefValue}" == "true" && "${prefValue2}" == "detail" ]]; then
				result="Passed"
			else
				result="Failed"
				comment="Firewall logging: Disabled"
			fi
		fi
else
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
					result="Passed After Remediation"
					comment="Firewall logging: Enabled"
				else
					result="Failed After Remediation"
					comment="Firewall logging: Disabled"
				fi
			fi	
		fi
	fi
fi
printReport