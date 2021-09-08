#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit='4.2 Enable "Show Wi-Fi status in menu bar" (Automated)'
orgScore="OrgScore4_2"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo -u <username> defaults -currentHost write com.apple.controlcenter.plist WiFi -int 18"
	
	appidentifier="com.apple.controlcenter"
	value="NSStatusItem Visible WiFi"
	prefValue=$(getPrefValuerunAsUser "${appidentifier}" "${value}")
	comment="Wi-Fi status in menu bar: Enabled"

	if [[ "${prefValue}" == "True" ]]; then
		result="Passed"
	else
		result="Failed"
		comment="Wi-Fi status in menu bar: Disabled"
		# Remediation
		if [[ "${remediateResult}" == "enabled" ]]; then
			sudo -u ${currentUser} defaults -currentHost write com.apple.controlcenter.plist WiFi -int 18
			killall ControlCenter
			sleep 2 2>&1

			# re-check
			appidentifier="com.apple.controlcenter"
			value="NSStatusItem Visible WiFi"
			prefValue=$(getPrefValuerunAsUser "${appidentifier}" "${value}")
			if [[ "${prefValue}" == "True" ]]; then
				result="Passed After Remediation"
				comment="Wi-Fi status in menu bar: Enabled"
			else
				result="Failed After Remediation"
			fi
		fi
	fi
fi
printReport