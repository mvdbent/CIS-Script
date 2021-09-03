#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="2"
audit="2.3.2 Secure screen saver corners (Automated)"
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
	if [[ "${prefIsManaged}" == "True" ]] || [[ "${prefIsManaged2}" == "True" ]] || [[ "${prefIsManaged3}" == "True" ]] || [[ "${prefIsManaged4}" == "True" ]]; then
		result="Passed"
	else
		if [[ "${prefValueAsUser}" == "5" ]] || [[ "${prefValue2AsUser}" == "5" ]] || [[ "${prefValue3AsUser}" == "5" ]] || [[ "${prefValue4AsUser}" == "5" ]]; then
			result="Passed"
		elif
			[[ "${prefValueAsUser}" == "10" ]] || [[ "${prefValue2AsUser}" == "10" ]] || [[ "${prefValue3AsUser}" == "10" ]] || [[ "${prefValue4AsUser}" == "10" ]]; then
				result="Passed"
			elif
				[[ "${prefValueAsUser}" == "13" ]] || [[ "${prefValue2AsUser}" == "13" ]] || [[ "${prefValue3AsUser}" == "13" ]] || [[ "${prefValue4AsUser}" == "13" ]]; then
					result="Passed"
				else
					result="Failed"
					comment="Secure screen saver corners: Disabled"
				fi
	fi
fi
value="${value}, ${value2}, ${value3}, ${value4}"
prefValue="${prefValueAsUser}, ${prefValue2AsUser}, ${prefValue3AsUser}, ${prefValue4AsUser}"
printReport