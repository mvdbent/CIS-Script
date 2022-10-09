#!/bin/zsh
# shellcheck shell=bash

# CIS-Script Passed After Remediation - List

auditfile=/Library/Security/Reports/CISBenchmarkReport.csv
echo "<result>$(awk -F ";" '$4 == "Passed After Remediation" { print $1 }' $auditfile)</result>"