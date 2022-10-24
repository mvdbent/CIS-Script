#!/bin/zsh
# shellcheck shell=bash

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source "${projectfolder}/Header.sh"

CISLevel="2"
audit="2.3.2 Ensure Screen Saver Corners Are Secure (Automated)"
orgScore="OrgScore2_3_2"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.dock > wvous-tl-corner=5, wvous-br-corner=10, wvous-bl-corner=13, wvous-tr-corner=0 - 5=Start Screen Saver, 10=Put Display to Sleep, 13=Lock Screen"

	appidentifier="com.apple.dock"
	value="wvous-bl-corner"
	value2="wvous-tl-corner"
	value3="wvous-tr-corner"
	value4="wvous-br-corner"
	prefValueAsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value}")
	prefValue2AsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value2}")
	prefValue3AsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value3}")
	prefValue4AsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value4}")
	prefIsManaged=$(getPrefIsManagedrunAsUser "${appidentifier}" "${value}")
	prefIsManaged2=$(getPrefIsManagedrunAsUser "${appidentifier}" "${value2}")
	prefIsManaged3=$(getPrefIsManagedrunAsUser "${appidentifier}" "${value3}")
	prefIsManaged4=$(getPrefIsManagedrunAsUser "${appidentifier}" "${value4}")
	comment="Secure screen saver corners: enabled"
	if [[ "${prefIsManaged}" != "6" ]] || [[ "${prefIsManaged2}" != "6" ]] || [[ "${prefIsManaged3}" != "6" ]] || [[ "${prefIsManaged4}" != "6" ]]; then
		result="Passed"
	else
		result="Failed"
		comment="Secure screen saver corners: Disabled"
	fi
fi
value="${value}, ${value2}, ${value3}, ${value4}"
prefValue="${prefValueAsUser}, ${prefValue2AsUser}, ${prefValue3AsUser}, ${prefValue4AsUser}"
printReport