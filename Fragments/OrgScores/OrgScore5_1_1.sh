#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit="5.1.1 Ensure Home Folders Are Secure (Automated)"
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
		result="Passed"
		comment="Home Folders: Secure"
	else 
		result="Failed"
		comment="Home Folders: Insecure"
		# Remediation
		if [[ "${remediateResult}" == "enabled" ]]; then
			IFS=$'\n'
			for userDirs in $( /usr/bin/find /System/Volumes/Data/Users -mindepth 1 -maxdepth 1 -type d -perm -1 | /usr/bin/grep -v "Shared" | /usr/bin/grep -v "Guest" ); do
			/bin/chmod og-rwx "$userDirs"
			done
			unset IFS
			# re-check
			homeFolders="$(find /Users -mindepth 1 -maxdepth 1 -type d -perm -1 2>&1 | grep -v "Shared" | grep -v "Guest" | wc -l | xargs)"
			if [[ "${homeFolders}" == "0" ]]; then
				result="Passed After Remediation"
				comment="Home Folders: Secure"
			else
				result="Failed After Remediation"
			fi
		fi	
	fi
fi
printReport