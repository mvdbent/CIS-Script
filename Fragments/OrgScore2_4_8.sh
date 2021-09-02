#!/bin/zsh

projectfolder=$(dirname "${0:A}")

source ${projectfolder}/Header.sh

CISLevel="1"
audit="2.4.8 Disable File Sharing (Automated)"
orgScore="OrgScore2_4_8"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo launchctl disable system/com.apple.smbd"

	smbEnabled=$(launchctl print-disabled system | grep -c '"com.apple.smbd" => false')
	if [[ "${smbEnabled}" == "0" ]]; then
		result="Passed"
		comment="File Sharing: Disabled"
	else
		result="Failed"
		comment="File Sharing: Enabled"

	fi
fi
printReport