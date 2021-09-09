#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit="4.4 Ensure http server is not running (Automated)"
orgScore="OrgScore4_4"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo launchctl disable system/org.apache.httpd"

	httpServer=$(launchctl print-disabled system 2>&1 | grep -c '"org.apache.httpd" => false')
	if [[ "${httpServer}" != "1" ]]; then
		result="Passed"
		comment="HTTP server service: Disabled"
	else 
		result="Failed"
		comment="HTTP server service: Enabled"
		# Remediation
		if [[ "${remediateResult}" == "enabled" ]]; then
			launchctl disable system/org.apache.httpd
			# re-check
			httpServer=$(launchctl print-disabled system 2>&1 | grep -c '"org.apache.httpd" => false')
			if [[ "${httpServer}" != "1" ]]; then
				result="Passed After Remediation"
				comment="HTTP server service: Disabled"
			else
				result="Failed After Remediation"
			fi
		fi
	fi
fi
printReport