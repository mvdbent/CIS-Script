#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit="2.4.11 Disable Media Sharing (Automated)"
orgScore="OrgScore2_4_11"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.preferences.sharing.SharingPrefsExtension > homeSharingUIStatus=0 > legacySharingUIStatus=0 > mediaSharingUIStatus=0"

	appidentifier="com.apple.preferences.sharing.SharingPrefsExtension"
	value="homeSharingUIStatus"
	value2="legacySharingUIStatus"
	value3="mediaSharingUIStatus"
	prefValueAsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value}")
	prefValue2AsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value2}")
	prefValue3AsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value3}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Media Sharing: Disabled"
	if [[ "${prefIsManaged}" == "true" && "${prefValueAsUser}" == "0" ]] && [[ "${prefValue2AsUser}" == "0" ]] && [[ "${prefValue3AsUser}" == "0" ]]; then
		result="Passed"
	else 
		if [[ "${prefValueAsUser}" == "0" ]] && [[ "${prefValue2AsUser}" == "0" ]] && [[ "${prefValue3AsUser}" == "0" ]]; then
			result="Passed"
		elif
			[[ "${prefValueAsUser}" == "" ]] && [[ "${prefValue2AsUser}" == "" ]] && [[ "${prefValue3AsUser}" == "" ]]; then
				result="Passed"
			else
				result="Failed"
				comment="Media Sharing: Enabled"
			fi
	fi
fi
value="${value}, ${value2}, ${value3}"
prefValue="${prefValueAsUser}, ${prefValue2AsUser}, ${prefValue3AsUser}"
printReport