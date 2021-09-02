#!/bin/zsh

projectfolder=$(dirname "${0:A}")

endResult=${projectfolder}/CISBenchmarkList.csv
echo OrgScore >> ${endResult}

# loop over fragments
for filePath in ${projectfolder}/Fragments/OrgScore*.sh; do

    # fragment name no extension
    fileName=$(basename ${filePath} .sh)
    echo ${fileName} >> ${endResult}

done