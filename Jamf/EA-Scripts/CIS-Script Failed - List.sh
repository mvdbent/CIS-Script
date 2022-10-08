#!/bin/zsh
# shellcheck shell=bash

# CIS-Script Failed - List

auditfile=/Library/Security/Reports/CISBenchmarkReport.csv
echo "<result>$(awk -F ";" '$4 == "Failed;" { print $1 }' $auditfile)</result>"