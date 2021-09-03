#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

endResult=${projectfolder}/Build/CISBenchmarkList.csv
echo OrgScore > ${endResult}

# loop over fragments
for filePath in ${projectfolder}/Fragments/OrgScores/OrgScore*.sh; do

    # fragment name no extension
    fileName=$(basename ${filePath} .sh)
    echo ${fileName} >> ${endResult}

done