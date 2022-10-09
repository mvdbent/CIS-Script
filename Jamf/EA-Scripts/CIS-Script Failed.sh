#!/bin/zsh
# shellcheck shell=bash

# CIS-Script Failed

auditfile=/Library/Security/Reports/CISBenchmarkReport.csv
echo "<result>$(grep -c "Failed;" "$auditfile")</result>"