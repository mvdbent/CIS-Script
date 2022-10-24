#!/bin/zsh
# shellcheck shell=bash

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source "${projectfolder}/Header.sh"

CISLevel="1"
audit="2.1.1 Ensure Bluetooth Is Disabled If No Devices Are Paired (Automated)"
orgScore="OrgScore2_1_1"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > defaults write /Library/Preferences/com.apple.Bluetooth ControllerPowerState -bool false"

	appidentifier="com.apple.controlcenter"
	value="Bluetooth"
	prefValueAsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value}")

	bluetoothEnabled=$(defaults read /Library/Preferences/com.apple.Bluetooth ControllerPowerState 2>/dev/null)
	comment="Paired Devices: ${prefValueAsUser}"
	if [[ "$bluetoothEnabled" == 0 ]]; then
		# bluetooth is off
		result="Passed"
	elif [[ "$bluetoothEnabled" == 1 ]] && [[ "${prefValueAsUser}" -gt 0 ]]; then
		# bluetooth is on, and there are paired devices
		result="Passed"
	else
		result="Failed"
		comment="Bluetooth On With No Paired Devices"
		# Remediation
		if [[ "${remediateResult}" == "enabled" ]]; then
			defaults write /Library/Preferences/com.apple.Bluetooth ControllerPowerState -bool false
			killall -HUP bluetoothd
			# re-check
			# our remediation is turning Bluetooth off so no need to check for paired devices
			bluetoothEnabled=$(defaults read /Library/Preferences/com.apple.Bluetooth ControllerPowerState 2>/dev/null)
			if [[ "$bluetoothEnabled" == 0 ]]; then
				result="Passed After Remediation"
			else
				result="Failed After Remediation"
			fi
		fi
	fi
fi
printReport
