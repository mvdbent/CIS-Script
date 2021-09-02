#!/bin/zsh

projectfolder=$(dirname "${0:A}")

source ${projectfolder}/Header.sh

CISLevel="1"
audit="2.11 Ensure EFI version is valid and being regularly checked (Automated)"
orgScore="OrgScore2_11"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	# Check for T2 chip.  
	securityChip=$(system_profiler SPiBridgeDataType 2>&1 | grep 'Model Name:' | grep -c 'T2')
	if [[ "${securityChip}" == "0" ]]; then
		countNotice=$((countNotice + 1))
		result="Not applicable"
		comment="EFI Firmware Integrity is not supported by this Mac. T2 Chip found."
	else
		method="Manual"
		remediate="If EFI does not pass the integrity check you may send a report to Apple. Backing up files and clean installing a known good Operating System and Firmware is recommended."
		efiStatus=$(/usr/libexec/firmwarecheckers/eficheck/eficheck --integrity-check | grep -c "No changes detected")
		if [[ "${efiStatus}" -gt 0 ]]; then
			countPassed=$((countPassed + 1))
			result="Passed"
			comment="EFI version: Valid"
		else
			countFailed=$((countFailed + 1))
			result="Failed"
			comment="EFI version: Invalid"
		fi
	fi
fi
printReport