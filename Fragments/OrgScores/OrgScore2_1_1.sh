#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit="2.1.1 Turn off Bluetooth, if no paired devices exist (Automated)"
orgScore="OrgScore2_1_1"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script - defaults write /Library/Preferences/com.apple.Bluetooth ControllerPowerState -bool false"

	connectable=$(system_profiler SPBluetoothDataType 2>&1 | grep -c "Paired: Yes")
	bluetoothEnabled=$(defaults read /Library/Preferences/com.apple.Bluetooth ControllerPowerState -bool)
	comment="Paired Devices: ${connectable}"
	# if [[ "$connectable" == 0 ]] && [[ "$bluetoothEnabled" == 0 ]]; then
	if [[ "$connectable" -gt 0 ]] && [[ "$bluetoothEnabled" == 1 ]] || [[ "$connectable" == 0 ]] && [[ "$bluetoothEnabled" == 0 ]]; then
		result="Passed"
	else
		result="Failed"
		comment="No Paired Devices"
		# Remediation
		if [[ "${remediateResult}" == "enabled" ]]; then
			defaults write /Library/Preferences/com.apple.Bluetooth ControllerPowerState -bool false
			killall -HUP bluetoothd
			# re-check
			connectable=$(system_profiler SPBluetoothDataType 2>&1 | grep -c "Paired: Yes")
			bluetoothEnabled=$(defaults read /Library/Preferences/com.apple.Bluetooth ControllerPowerState -bool)
			if [[ "$connectable" == 0 ]] && [[ "$bluetoothEnabled" == 0 ]]; then
				result="Passed After Remediation"
			else
				result="Failed After Remediation"
			fi
		fi
	fi
fi
printReport