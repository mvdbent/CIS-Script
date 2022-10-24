#!/bin/zsh
# shellcheck shell=bash

script_dir=$(dirname "${0:A}")
projectfolder=$(dirname "$script_dir")

# destination
endPath="${projectfolder}/Build"
mkdir -p "${endPath}"
endResult="${endPath}/CISBenchmarkList.csv"

echo OrgScore > "${endResult}"

# sort the filenames numerically
setopt NUMERIC_GLOB_SORT

# loop over fragments
for filePath in "${projectfolder}/Fragments/OrgScores/"OrgScore*.sh; do

    # fragment name no extension
    fileName=$(basename "${filePath}" .sh)
    echo "${fileName}" >> "${endResult}"

done