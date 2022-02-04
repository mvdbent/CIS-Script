#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit="2.3.3 Audit Lock Screen and Start Screen Saver Tools (Manual)"
orgScore="OrgScore2_3_3"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Manual"
	remediate="Familiarise users with screen lock tools or corner to Start Screen Saver"
	
	appidentifier="com.apple.dock"
	value="wvous-bl-corner"
	value2="wvous-tl-corner"
	value3="wvous-tr-corner"
	value4="wvous-br-corner"
	prefValueAsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value}")
	prefValue2AsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value2}")
	prefValue3AsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value3}")
	prefValue4AsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value4}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="End-users are familiar with screen lock tools or Hot Corners"
	if [[ "${prefIsManaged}" == "true" ]]; then
		result="Passed"
	else
		if [[ "${prefValueAsUser}" != "1" ]] || [[ "${prefValue2AsUser}" != "1" ]] || [[ "${prefValue3AsUser}" != "1" ]] || [[ "${prefValue4AsUser}" != "1" ]]; then
			result="Passed"
		else
			result="Failed"
			comment="Familiarise users with screen lock tools or corner to Start Screen Saver"
		fi
	fi
fi
value=""
prefValue=""
printReport