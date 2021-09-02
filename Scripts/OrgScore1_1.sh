#!/bin/zsh
####################################################################################################
#        License information
####################################################################################################
#
#        THE SCRIPTS ARE PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, 
#        INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY 
#        AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
#        I BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, 
#        OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
#        SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
#        INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
#        CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
#        ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF 
#        THE POSSIBILITY OF SUCH DAMAGE.
#
####################################################################################################
# 
# Version 0.9
# Written by: Mischa van der Bent
#
# DESCRIPTION
# This script creates a report of the audit based on orgSecurityScore or for each listed item
# in the CIS Benchmark script of Jamf here https://github.com/jamf/CIS-for-macOS-Catalina-CP
# 
# REQUIREMENTS
# Compatible with Big Sure macOS 11.x
# 
####################################################################################################
####################################################################################################

export PATH=/usr/bin:/bin:/usr/sbin:/sbin

### Directory/Path/Variables
projectfolder="/Library/Security"
# projectfolder=$(dirname "$0")
plistlocation="/Library/Managed Preferences/com.cis.benchmark.plist"
currentUser=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ { print $3 }')

# counters
countChecked=0
countPassed=0
countFailed=0
countNotice=0
countRemediated=0
countPassedAfterRemediated=0
countFailedAfterRemediation=0

### Functions
function runAudit () {
	## Check if scoring file is present
	if [[ ! -e ${plistlocation} ]]; then
		## No scoring file present, reporting all
		auditResult="1"
		countChecked=$((countChecked + 1))
		scored=""
		echo "OrgScore ${audit}"
	else
		auditResult=$(defaults read "${plistlocation}" "${orgScore}" 2>&1)
		if [[ "${auditResult}" == "1" ]]; then
			countChecked=$((countChecked + 1))
			scored="Scored"
			echo "OrgScore ${audit}"
		else
			scored="NOT Scored"
		fi
	fi
}

function runAsUser() {
	if [[ "${currentUser}" != "loginwindow" ]]; then
		uid=$(id -u "${currentUser}")
		launchctl asuser "$uid" sudo -u "${currentUser}" "$@"
	fi
}

function getPrefValue { # $1: domain, $2: key
	python -c "from Foundation import CFPreferencesCopyAppValue; print(CFPreferencesCopyAppValue('$2', '$1'))"
}

function getPrefValueNested { # $1: domain, $2: key
	python -c "from Foundation import CFPreferencesCopyAppValue; print(CFPreferencesCopyAppValue('$2', '$1'))['$3']"
}

function getPrefValuerunAsUser { # $1: domain, $2: key
	runAsUser python -c "from Foundation import CFPreferencesCopyAppValue; print(CFPreferencesCopyAppValue('$2', '$1'))"
}

function getPrefIsManaged { # $1: domain, $2: key
	python -c "from Foundation import CFPreferencesAppValueIsForced; print(CFPreferencesAppValueIsForced('$2', '$1'))"
}

function getPrefIsManagedrunAsUser { # $1: domain, $2: key
	runAsUser python -c "from Foundation import CFPreferencesAppValueIsForced; print(CFPreferencesAppValueIsForced('$2', '$1'))"
}

### Functions
function CISBenchmarkReportFile () {
	CISBenchmarkReportPath=${projectfolder}/Reports
	CISBenchmarkReport=${CISBenchmarkReportPath}/CISBenchmarkReport-$(date '+%d-%m-%Y_%Hh%Mm%Ss').csv
	if [[ ! -d ${CISBenchmarkReportPath} ]]; then
		/bin/mkdir -p "${CISBenchmarkReportPath}"
	fi
}

function CISBenchmarkRemediationReport () {
	CISBenchmarkReportPath=${projectfolder}/Reports
	CISBenchmarkRemediation=${CISBenchmarkReportPath}/CISBenchmarkRemediationReport.txt
	if [[ ! -d ${CISBenchmarkReportPath} ]]; then
		/bin/mkdir -p "${CISBenchmarkReportPath}"
	fi
}

function printReport(){
	echo "${audit};${CISLevel};${scored};${result};${prefIsManaged};${appidentifier};${value};${prefValue};${method};${comment};${remediate}">>"${CISBenchmarkReport}"
}

function emptyVariables(){
	prefIsManaged=""
	appidentifier=""
	value=""
	prefValue=""
	result=""
	method=""
	comment=""
	remediate=""
}

# Start Security report script
echo ""
echo "*** Security report started - $(date -u)"

# Check for admin/root permissions
if [[ "$(id -u)" != "0" ]]; then
	echo ""
	echo "*** Script must be run as root, or have root privileges (ie. sudo)." 1>&2
	echo "*** Quitting..."
	echo ""
	exit 1
fi

# Check for Big sur
osVersion=$(sw_vers -productVersion)
buildVersion=$(sw_vers -buildVersion)
if [[ "$osVersion" != "11."* ]]; then
	echo ""
	echo "*** This script support macOS Big Sur only"
	echo "*** Quitting..."
	echo ""
	exit 1
	else
	echo "*** Current version - macOS Big Sur ${osVersion} (${buildVersion})" 1>&2
	echo ""
fi

# Create csv file
CISBenchmarkReportFile

# Create csv file headers
echo "Audit Number;Level;Scored;Result;Managed;Preference domain;Option;Value;Method;Comments;Remediate" >> "${CISBenchmarkReport}"

#####################################################################################################################################
#####################################################################################################################################
#################################################### DO NOT EDIT BELOW THIS LINE ####################################################
#####################################################################################################################################
#####################################################################################################################################

CISLevel="1"
audit="1.1 Verify all Apple-provided software is current (Automated)"
orgScore="OrgScore1_1"
emptyVariables
method="Script"
remediate="Script > sudo /usr/sbin/softwareupdate --install --restart --recommended"
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	countAvailableSUS=$(softwareupdate -l 2>&1 | grep -c "*")
	if [[ "${countAvailableSUS}" == "0" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="Apple Software is Current"
	else
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="Available Updates: ${countAvailableSUS}, verify all Apple provided software is current"
	fi
fi
printReport