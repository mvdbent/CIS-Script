#!/bin/zsh
# shellcheck shell=bash

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source "${projectfolder}/Header.sh"

CISLevel="2"
audit="5.9 Ensure system is set to hibernate (Automated)"
orgScore="OrgScore5_9"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo pmset -a standbydelayhigh 600 && sudo pmset -a standbydelaylow 600 && sudo pmset -a highstandbythreshold 90 && sudo pmset -a destroyfvkeyonstandby 1"

	hibernateValue=$(pmset -g | grep standbydelaylow 2>&1 | awk '{print $2}')
	macType=$(system_profiler SPHardwareDataType 2>&1 | grep -c MacBook)
	comment="Hibernate: Enabled"
	if [[ "$macType" -ge 0 ]]; then
		if [[ "$hibernateValue" == "" ]] || [[ "$hibernateValue" -gt 600 ]]; then
			result="Passed"
		else 
			result="Failed"
			comment="Hibernate: Disabled"
			# Remediation
			if [[ "${remediateResult}" == "enabled" ]]; then
				pmset -a standbydelayhigh 600
				pmset -a standbydelaylow 600
				pmset -a highstandbythreshold 90
				pmset -a destroyfvkeyonstandby 1
				# re-check
				hibernateValue=$(pmset -g | grep standbydelaylow 2>&1 | awk '{print $2}')
				if [[ "$hibernateValue" == "" ]] || [[ "$hibernateValue" -gt 600 ]]; then
					result="Passed After Remediation"
					comment="Hibernate: Enabled"
				else
					result="Failed After Remediation"
				fi
			fi
		fi
	else
		result="Passed"
	fi
fi
printReport