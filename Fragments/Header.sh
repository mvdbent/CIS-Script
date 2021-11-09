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
####################################################################################################
# 
#        Written by: Mischa van der Bent
#
#        DESCRIPTION
#        This script is inspired by the CIS Benchmark script of Jamf Professional Services 
#        https://github.com/jamf/CIS-for-macOS-Catalina-CP
#        And will look for a managed Configuration Profile (com.cis.benchmark.plist) and checks, 
#        remediation (if needend) and report.
#        The Security Score can be set with the Jamf Pro Custom Schema json file.
#        Reports are stored in /Library/Security/Reports.
# 
#        REQUIREMENTS
#        Compatible with Big Sure macOS 11.x
#        Compatible with Monterey macOS 12.x 
# 
####################################################################################################
####################################################################################################

export PATH=/usr/bin:/bin:/usr/sbin:/sbin

####################################################################################################
#        Directory/Path/Variables
####################################################################################################

CISBenchmarkReportPath="/Library/Security/Reports"
CISBenchmarkReport=${CISBenchmarkReportPath}/CISBenchmarkReport.csv
plistlocation="/Library/Managed Preferences/com.cis.benchmark.plist"
currentUser=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ { print $3 }')

####################################################################################################
#        Functions
####################################################################################################

function help(){
  echo
  echo "The following options are available:"
  echo 
  echo "	-f	--fullreport	Print Full Report"
  echo "	-h	--help		Displays this message or details on a specific verb"
  echo "	-r	--remediate	Enable Remediation"
  echo 
  echo "EXAMPLES"
  echo "    ./CISBenchmarkScript.sh -f"
  echo "            Run script to print Full Report"
  echo 
  echo "    ./CISBenchmarkScript.sh -r"
  echo "            Run script with Remediation enabled"
  echo
  echo "    ./CISBenchmarkScript.sh -rf"
  echo "            Run script with Remediation enabled and print Full Report "
  echo 
  exit
}

case $1 in 
    -f | --fullreport)
        argumentHeaderFunctionName="fullHeader"
        argumentReportFunctionName="fullReport"
        argumentRemediateVariable="disabled"
    ;;
    -fr | -rf | --fullreport-remediate | --remediate-fullreport)
        argumentHeaderFunctionName="fullHeader"
        argumentReportFunctionName="fullReport"
        argumentRemediateVariable="enabled"
    ;;
    -h | --help)
        help
    ;;
    -r | --remediate)
        argumentHeaderFunctionName="shortHeader"
        argumentReportFunctionName="shortReport"
        argumentRemediateVariable="enabled"
    ;;
    *)
        argumentHeaderFunctionName="shortHeader"
        argumentReportFunctionName="shortReport"
        argumentRemediateVariable="disabled"
    ;;
esac

function runAudit() {
	## Check if scoring file is present
	if [[ ! -e ${plistlocation} ]]; then
		## No scoring file present, reporting all
		auditResult="1"
		scored=""
		echo "OrgScore ${audit}"
	else
		auditResult=$(defaults read "${plistlocation}" "${orgScore}" 2>&1)
		if [[ "${auditResult}" == "1" ]]; then
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

function getPrefValue() { # $1: domain, $2: key
    osascript -l JavaScript << EndOfScript
        ObjC.import('Foundation');
        ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('$1').objectForKey('$2'))
EndOfScript
}

function getPrefValueNested() { # $1: domain, $2: key, $3: nestedkey
    osascript -l JavaScript << EndOfScript
        ObjC.import('Foundation');
        ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('$1').objectForKey('$2').objectForKey('$3'))
EndOfScript
}

function getPrefValuerunAsUser() { # $1: domain, $2: key
	runAsUser osascript -l JavaScript << EndOfScript
        ObjC.import('Foundation');
        ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('$1').objectForKey('$2'))
EndOfScript
}

function getPrefIsManaged() { # $1: domain, $2: key
    osascript -l JavaScript << EndOfScript
    ObjC.import('Foundation')
    ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('$1').objectIsForcedForKey('$2'))
EndOfScript
}

function getPrefIsManagedrunAsUser() { # $1: domain, $2: key
	runAsUser     osascript -l JavaScript << EndOfScript
    ObjC.import('Foundation')
    ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('$1').objectIsForcedForKey('$2'))
EndOfScript
}

function CISBenchmarkReportFolder() {
	if [[ -d ${CISBenchmarkReportPath} ]]; then
		rm -Rf "${CISBenchmarkReportPath}"
		mkdir -p "${CISBenchmarkReportPath}"
		else
		mkdir -p "${CISBenchmarkReportPath}"
	fi
}

function shortHeader(){
	echo "Audit Number;Level;Scoring;Result;Managed;Method;Comments" >> "${CISBenchmarkReport}"
}

function fullHeader(){
	echo "Audit Number;Level;Scoring;Result;Managed;Preference domain;Option;Value;Method;Comments;Remediate" >> "${CISBenchmarkReport}"
}

function shortReport(){
	echo "${audit};${CISLevel};${scored};${result};${prefIsManaged};${method};${comment}">>"${CISBenchmarkReport}"
}

function fullReport(){
	echo "${audit};${CISLevel};${scored};${result};${prefIsManaged};${appidentifier};${value};${prefValue};${method};${comment};${remediate}">>"${CISBenchmarkReport}"
}

function printReport(){
	## Check if scoring file is present
	if [[ ! -e ${plistlocation} ]]; then
		## No scoring file present, check arguments
		${argumentReportFunctionName}
	else
		reportSetting=$(defaults read "${plistlocation}" report 2>&1)
		if [[ "${reportSetting}" == "full" ]]; then
			fullReport
		else
			shortReport
		fi
	fi
}

function printReportHeaders(){
	## Check if scoring file is present
	if [[ ! -e ${plistlocation} ]]; then
		## No scoring file present, check arguments
		${argumentHeaderFunctionName}
	else
		reportSetting=$(defaults read "${plistlocation}" report 2>&1)
		if [[ "${reportSetting}" == "full" ]]; then
			fullHeader
		else
			shortHeader
		fi
	fi
}

function runRemediate() {
	## Check if scoring file is present
	if [[ ! -e ${plistlocation} ]]; then
		## No scoring file present, check arguments
		remediateResult="${argumentRemediateVariable}"
	else
		remediateResult=$(defaults read "${plistlocation}" "remediate" 2>&1)
		if [[ "${remediateResult}" == "enabled" ]]; then
			remediateResult="enabled"
		else
			remediateResult="disabled"
		fi
	fi
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

function killcfpref(){
	## Restart daemon responsible for prefrence caching
	echo "Killing cfprefs daemon "
	killall cfprefsd
}

####################################################################################################
#        Start Security report script
####################################################################################################

echo ""
echo "*** Security report started - $(date -u)"

# Check for macOS version
osVersion=$(sw_vers -productVersion)
buildVersion=$(sw_vers -buildVersion)
if [[ "$osVersion" != "10.15."* ]] && [[ "$osVersion" != "11."* ]] && [[ "$osVersion" != "12."* ]]; then
		echo ""
		echo "*** This script support macOS Catalina, Big Sur and Monterey only"
		echo
		echo "*** Quitting..."
		echo ""
		exit 1
	else
		if [[ "$osVersion" = "10.15."* ]]; then
			echo "*** Current version - macOS Catalina ${osVersion} (${buildVersion})"
			echo "" 1>&2
		elif [[ "$osVersion" = "11."* ]]; then
			echo "*** Current version - macOS Big Sur ${osVersion} (${buildVersion})"
			echo "" 1>&2
		elif [[ "$osVersion" = "12."* ]]; then
			echo "*** Current version - macOS Monterey ${osVersion} (${buildVersion})"
			echo "" 1>&2
		fi
	fi

# Check for admin/root permissions
if [[ "$(id -u)" != "0" ]]; then
	echo "*** Script must be run as root, or have root privileges (ie. sudo)." 1>&2
	echo
	echo "*** Use -h --help for more instructions"
	echo
	echo "*** Quitting..."
	echo ""
	exit 1
fi

# Create report Folder/Files
CISBenchmarkReportFolder

# Create csv file headers
printReportHeaders

# check remediation
runRemediate

####################################################################################################
####################################################################################################
################################### DO NOT EDIT BELOW THIS LINE ####################################
####################################################################################################
####################################################################################################
