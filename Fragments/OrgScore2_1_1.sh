#!/bin/zsh

projectfolder=$(dirname "${0:A}")

source ${projectfolder}/Header.sh

CISLevel="1"
audit="2.1.1 Turn off Bluetooth, if no paired devices exist (Automated)"
orgScore="OrgScore2_1_1"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.MCXBluetooth > DisableBluetooth=true"

	appidentifier="com.apple.Bluetooth"
	value="ControllerPowerState"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	connectable=$(system_profiler SPBluetoothDataType 2>&1 | grep -c Connectable)
	comment="Paired Devices: ${connectable}"
	if [[ "${prefIsManaged}" == "True" &&  "${prefValue}" == "True" ]]; then
		result="Passed"
	else
		if [[ "${prefValue}" == "True" ]]; then
			result="Passed"
		else
			if [[ "${connectable}" != "0" ]]; then
				result="Passed"
			else
			result="Failed"
			comment="No Paired Devices"
			fi
		fi
	fi
fi
printReport