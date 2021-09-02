#!/bin/zsh

projectfolder=$(dirname "${0:A}")

endResult=${projectfolder}/Scripts/CISBenchmarkRemediationReport.sh

echo "#!/bin/zsh" > ${endResult}

cat ${projectfolder}/Fragments/Header.sh >> ${endResult}

for filePath in ${projectfolder}/Fragments/OrgScore*.sh; do

    fileName=$(basename ${filePath})
    echo "Add ${fileName} to script"

    tail -n +6 ${filePath} >> ${endResult}
    echo >> ${endResult}

done

chmod +x ${endResult}
