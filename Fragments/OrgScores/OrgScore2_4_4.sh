#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

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
		result="Passed"
		comment="Printer Sharing: Disabled"
	else
		result="Failed"
		comment="Printer Sharing: Enabled"
		# Remediation
		if [[ "${remediateResult}" == "enabled" ]]; then
			sudo /usr/sbin/cupsctl --no-share-printers
			# re-check
			printerSharing=$(cupsctl | grep "share_printers")
			if [[ "${printerSharing}" == "_share_printers=0" ]]; then
				result="Passed After Remdiatio"
				comment="Printer Sharing: Disabled"
			else
				result="Failed After Remediation"
			fi
		fi
	fi
fi
printReport