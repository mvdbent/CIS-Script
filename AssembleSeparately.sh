#!/bin/zsh

projectfolder=$(dirname "${0:A}")

fragementName=${projectfolder}/Fragments/OrgScore1_1.sh
endResult=${projectfolder}/Scripts/OrgScore1_1.sh

echo "#!/bin/zsh" > ${endResult}

cat ${projectfolder}/Fragments/Header.sh >> ${endResult}

tail -n +6 ${fragementName} >> ${endResult}

echo >> ${endResult}

cat ${projectfolder}/Fragments/Footer.sh >> ${endResult}

chmod +x ${endResult}