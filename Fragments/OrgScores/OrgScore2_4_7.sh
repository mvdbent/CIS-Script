#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit="2.4.7 Disable Bluetooth Sharing (Automated)"
orgScore="OrgScore2_4_7"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo -u 'CURRENT_USER' defaults -currentHost write com.apple.Bluetooth PrefKeyServicesEnabled -bool false"

	appidentifier="com.apple.Bluetooth"
	value="PrefKeyServicesEnabled"
	prefValueAsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Bluetooth Sharing: Disabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValueAsUser}" == "False" ]]; then
		result="Passed"
	else
		if [[ "${prefValueAsUser}" == "False" ]]; then
			result="Passed"
		else
			result="Failed"
			comment="Bluetooth Sharing: Enabled"
		fi
	fi
fi
printReport