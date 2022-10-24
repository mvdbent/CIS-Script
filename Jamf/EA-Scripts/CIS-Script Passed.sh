#!/bin/zsh
# shellcheck shell=bash

# CIS-Script Passed

auditfile=/Library/Security/Reports/CISBenchmarkReport.csv
echo "<result>$(grep -c "Passed" "$auditfile")</result>"