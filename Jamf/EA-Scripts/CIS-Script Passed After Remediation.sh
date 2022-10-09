#!/bin/zsh
# shellcheck shell=bash

# CIS-Script Passed After Remediation

auditfile=/Library/Security/Reports/CISBenchmarkReport.csv
echo "<result>$(grep -c "Passed After Remediation" "$auditfile")</result>"