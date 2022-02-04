#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit="2.11 Ensure EFI Version Is Valid and Checked Regularly (Automated)"
orgScore="OrgScore2_11"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Manual"
	remediate="If EFI does not pass the integrity check you may send a report to Apple. Backing up files and clean installing a known good Operating System and Firmware is recommended."
	
	comment="EFI version: Valid"
	# Check for Apple Silicon
	if [[ "$(sysctl -in hw.optional.arm64)" == '1' ]]; then
	result="Not Applicable"
	comment="Apple Silicon"
	else
	# Check for T2 chip.
	securityChip=$(system_profiler SPiBridgeDataType 2>&1 | grep -c 'Model Name: Apple T2 Security Chip')
		if [[ "${securityChip}" == "1" ]]; then
			t2Check=$(launchctl list | grep -c com.apple.driver.eficheck)
			if [[ "$t2Check" == "1" ]] then
			result="Passed"
			else
				result="Failed"
				comment="EFI version: Invalid"
			fi
		else
			efiStatus=$(/usr/libexec/firmwarecheckers/eficheck/eficheck --integrity-check | grep -c "No changes detected")
			if [[ "${efiStatus}" -gt 0 ]]; then
				result="Passed"
			else
				result="Failed"
				comment="EFI version: Invalid"
			fi
		fi
	fi
fi
printReport