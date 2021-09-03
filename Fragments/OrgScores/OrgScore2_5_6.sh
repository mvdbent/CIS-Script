#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="2"
audit="2.5.6 Disable sending diagnostic and usage data to Apple (Automated)"
orgScore="OrgScore2_5_6"
emptyVariables
# Verify organizational score
runAudit
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.SubmitDiagInfo > AutoSubmit=false - payload > com.apple.applicationaccess > allowDiagnosticSubmission=false"

	appidentifier="com.apple.SubmitDiagInfo"
	value="AutoSubmit"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Sending diagnostic and usage data to Apple: Disabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValue}" == "False" ]]; then
		result="Passed"
	else
		if [[ "${prefValue}" == "False" ]]; then
			result="Passed"
		else
			diagnosticEnabled=$(defaults read /Library/Application\ Support/CrashReporter/DiagnosticMessagesHistory.plist AutoSubmit)
			if [[ "${diagnosticEnabled}" == "0" ]]; then
				result="Passed"
			else
				result="Failed"
				comment="Sending diagnostic and usage data to Apple: Enabled"
			fi
		fi
	fi
fi
printReport