#!/bin/zsh
# shellcheck shell=bash

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source "${projectfolder}/Header.sh"

CISLevel="1"
audit="5.1.5 Ensure Sealed System Volume (SSV) Is Enabled (Automated)"
orgScore="OrgScore5_1_5"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate='Script > sudo /usr/bin/csrutil authenticated-root enable'

	authenticatedRoot="$(csrutil authenticated-root | /usr/bin/grep -c 'enabled')"
	if [[ "${authenticatedRoot}" == "1" ]]; then
		result="Passed"
		comment="Authenticated Root: Enabled"
	else 
		result="Failed"
		comment="Authenticated Root: Disabled"
		# Remediation
		if [[ "${remediateResult}" == "enabled" ]]; then
			csrutil authenticated-root enable
			# re-check
			authenticatedRoot="$(csrutil authenticated-root | /usr/bin/grep -c 'enabled')"
			if [[ "${authenticatedRoot}" == "1" ]]; then
				result="Passed After Remediation"
				comment="Authenticated Root: Enabled"
			else
				result="Failed After Remediation"
			fi
		fi
	fi
fi
printReport