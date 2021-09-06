#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit='2.2.1 Enable "Set time and date automatically" (Automated)'
orgScore="OrgScore2_2_1"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.timed > TMAutomaticTimeOnlyEnabled=true"

	appidentifier="com.apple.timed"
	value="TMAutomaticTimeOnlyEnabled"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Time and date automatically: Enabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValue}" == "1" ]]; then
		result="Passed"
	else
		if [[ "${prefValue}" == "1" ]]; then
			result="Passed"
		else
			networkTime=$(systemsetup -getusingnetworktime)
			if [[ "${networkTime}" = "Network Time: On" ]]; then
				result="Passed"
			else
				result="Failed"
				comment="Time and date automatically: Disabled"
				# Remediation
				if [[ "${remediateResult}" == "enabled" ]]; then
				systemsetup -setusingnetworktime on >/dev/null 2>&1
				# re-check
				networkTime=$(systemsetup -getusingnetworktime)
					if [[ "${networkTime}" = "Network Time: On" ]]; then
						result="Passed After Remdiation"
						comment="Time and date automatically: Enabled"
					else
						result="Failed After Remediation"
					fi
				fi
			fi
		fi
	fi
fi
printReport