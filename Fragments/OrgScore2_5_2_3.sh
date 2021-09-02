#!/bin/zsh

projectfolder=$(dirname "${0:A}")

source ${projectfolder}/Header.sh

CISLevel="1"
audit="2.5.2.3 Enable Firewall Stealth Mode (Automated)"
orgScore="OrgScore2_5_2_3"
emptyVariables
# Verify organizational score
runAudit
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.security.firewall > EnableStealthMode=true"

	appidentifier="com.apple.security.Firewall"
	value="EnableStealthMode"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Firewall Stealth Mode: Enabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValue}" == "True" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
	else
		if [[ "${prefValue}" == "True" ]]; then
			countPassed=$((countPassed + 1))
			result="Passed"
		else
			stealthEnabled=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getstealthmode | grep -c "Stealth mode enabled")
			if [[ "$stealthEnabled" == "1" ]]; then
				countPassed=$((countPassed + 1))
				result="Passed"
			else
				countFailed=$((countFailed + 1))
				result="Failed"
				comment="Firewall Stealth Mode: Disabled"
			fi
		fi
	fi
fi
printReport