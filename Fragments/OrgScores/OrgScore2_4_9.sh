#!/bin/zsh
# shellcheck shell=bash

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source "${projectfolder}/Header.sh"

CISLevel="1"
audit="2.4.9 Ensure Remote Management Is Disabled (Automated)"
orgScore="OrgScore2_4_9"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -deactivate -stop"
	screenSharing=$(runAsUser launchctl list | grep com.apple.RemoteDesktop.agent | awk '{ print $1 }')
	if [[ "$screenSharing" == "-" ]]; then
		result="Passed"
		comment="Remote Management: Disabled"
	else
		result="Failed"
		comment="Remote Management: Enabled"
	# Remediation
		if [[ "${remediateResult}" == "enabled" ]]; then
		sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -deactivate -stop
		# re-check
			screenSharing=$(runAsUser launchctl list | grep com.apple.RemoteDesktop.agent | awk '{ print $1 }')
			if [[ "$screenSharing" == "-" ]]; then	
				result="Passed After Remediation"
				comment="Remote Management: Disabled"
			else
				result="Failed After Remediation"
			fi
		fi
	fi
fi
printReport