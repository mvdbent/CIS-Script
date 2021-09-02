#!/bin/zsh

projectfolder=$(dirname "${0:A}")

source ${projectfolder}/Header.sh

CISLevel="1"
audit="5.1.1 Secure Home Folders (Automated)"
orgScore="OrgScore5_1_1"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo chmod og-rwx 'HomeFolders'"

	homeFolders="$(find /Users -mindepth 1 -maxdepth 1 -type d -perm -1 2>&1 | grep -v "Shared" | grep -v "Guest" | wc -l | xargs)"
	if [[ "${homeFolders}" == "0" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="Home Folders: Secure"
	else 
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="Home Folders: Insecure"
	fi
fi
printReport