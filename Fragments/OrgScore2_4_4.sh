#!/bin/zsh

projectfolder=$(dirname "${0:A}")

source ${projectfolder}/Header.sh

CISLevel="1"
audit="2.4.4 Disable Printer Sharing (Automated)"
orgScore="OrgScore2_4_4"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo /usr/sbin/cupsctl --no-share-printers"

	printerSharing=$(cupsctl | grep "share_printers")
	if [[ "${printerSharing}" == "_share_printers=0" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="Printer Sharing: Disabled"
	else
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="Printer Sharing: Enabled"
	fi
fi
printReport