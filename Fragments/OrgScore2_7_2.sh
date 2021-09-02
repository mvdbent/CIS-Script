#!/bin/zsh

projectfolder=$(dirname "${0:A}")

source ${projectfolder}/Header.sh

CISLevel="1"
audit="2.7.2 Time Machine Volumes Are Encrypted (Automated)"
orgScore="OrgScore2_7_2"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Manual"
	remediate="Manual > Set encryption through Disk Utility or diskutil in terminal"
	
	tmDestination=$(tmutil destinationinfo | grep -i NAME | awk '{print $2}')
	tmDrives=$(tmutil destinationinfo | grep -c "NAME")
	tmVolumeEncrypted=$(diskutil info "${tmDestination}" 2>&1 | grep -c "Encrypted: Yes")
	if [[ "${tmDrives}" -gt "0" && "${tmVolumeEncrypted}" -gt "0" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="Time Machine Volumes: Encrypted"
	else 
		if [[ "${tmDrives}" == "0" ]]; then
			countPassed=$((countPassed + 1))
			result="Passed"
			comment="No Time Machine Volumes available"
		else
			countFailed=$((countFailed + 1))
			result="Failed"
			comment="Time Machine Volumes: Unencrypted"
		fi
	fi
fi
printReport