
####################################################################################################
####################################################################################################

# Creation date CISBenchmarkReport
if [[ "${argumentHeaderFunctionName}" ==  "fullHeader" ]] || [[ "${reportSetting}" == "full" ]]; then
		## add creation date
		echo ";;;;;;;;;;" >> "${CISBenchmarkReport}"
		if [[ "$osVersion" = "10.15."* ]]; then
			echo "Security report - $(date) - macOS Catalina ${osVersion} (${buildVersion});;;;;;;;;;" >> "${CISBenchmarkReport}"
		elif [[ "$osVersion" = "11."* ]]; then
			echo "Security report - $(date) - macOS Big Sur ${osVersion} (${buildVersion});;;;;;;;;;" >> "${CISBenchmarkReport}"
		elif [[ "$osVersion" = "12."* ]]; then
			echo "Security report - $(date) - macOS Monterey ${osVersion} (${buildVersion});;;;;;;;;;" >> "${CISBenchmarkReport}"
		fi
        # echo "Security report - $(date);;;;;;;;;;" >> "${CISBenchmarkReport}"
	else
		echo ";;;;;;" >> "${CISBenchmarkReport}"
		if [[ "$osVersion" = "10.15."* ]]; then
			echo "Security report - $(date) - macOS Catalina ${osVersion} (${buildVersion});;;;;;" >> "${CISBenchmarkReport}"
		elif [[ "$osVersion" = "11."* ]]; then
			echo "Security report - $(date) - macOS Big Sur ${osVersion} (${buildVersion});;;;;;" >> "${CISBenchmarkReport}"
		elif [[ "$osVersion" = "12."* ]]; then
			echo "Security report - $(date) - macOS Monterey ${osVersion} (${buildVersion});;;;;;" >> "${CISBenchmarkReport}"
		fi
        # echo "Security report - $(date);;;;;;" >> "${CISBenchmarkReport}"
fi

# open "${CISBenchmarkReportPath}"
# open -a Numbers "${CISBenchmarkReport}"
# open -a "Microsoft Excel" "${CISBenchmarkReport}"

####################################################################################################
####################################################################################################
######################################## END OF THE SCRIPT #########################################
####################################################################################################
####################################################################################################
