#!/bin/zsh
# shellcheck shell=bash

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source "${projectfolder}/Header.sh"

CISLevel="1"
audit="3.1 Ensure Security Auditing Is Enabled (Automated)"
orgScore="OrgScore3_1"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.auditd.plist"
	
	auditdEnabled=$(launchctl list 2>&1 | grep -c auditd)
	if [[ "${auditdEnabled}" -gt "0" ]]; then
		result="Passed"
		comment="Security auditing: Enabled"
	else 
		result="Failed"
		comment="Security auditing: Disabled"
	# Remediation
		if [[ "${remediateResult}" == "enabled" ]]; then
			launchctl load -w /System/Library/LaunchDaemons/com.apple.auditd.plist
		# re-check
			auditdEnabled=$(launchctl list 2>&1 | grep -c auditd)
			if [[ "${auditdEnabled}" -gt "0" ]]; then
				result="Passed After Remediation"
				comment="Security auditing: Enabled"
			else 
				result="Failed After Remediation"
			fi
		fi
	fi
fi
printReport