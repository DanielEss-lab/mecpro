#!/bin/bash

current_date=`date +"%B %e, %Y"`
major_version_number="0"
minor_version_number="5"

# $1 is an array of files, $2 is the source directory of the files
function moveFiles {
	cp -R $1/. TempZipDir/
}

ScriptFiles=(hours2time InstallMecpro.sh mecpcheck.sh mecpnext mecpstatus_helper rung09 mecpcheck_old.sh mecpdata mecpstart  mecpstatus) # all files located in scripts/
TemplateFiles=(mecpraw.template pbs_submission.template) # all files located in templates/
PythonSourceFiles=(atom.py gaussian.py getwalltime.py mecpinput_debugging.py mecpinput.py mecp.py rotate.py)
ExampleFiles=(example1.mecp example2-error.mecp example2.mecp)
DocsFiles=(README.txt LICENSE.txt)

if [ -d "TempZipDir" ] ; then
	rm -rf TempZipDir
fi

mkdir TempZipDir

moveFiles scripts
moveFiles templates
moveFiles pylib
moveFiles examples
moveFiles docs

# moveFiles ScriptFiles[@] scripts
# moveFiles TemplateFiles[@] templates
# moveFiles PythonSourceFiles[@] pylib
# moveFiles ExampleFiles[@] examples
# moveFiles DocsFiles[@] docs

sed -i "s~DATE_GOES_HERE~$current_date~g" TempZipDir/README.txt
sed -i "s~VERSION_GOES_HERE~Version $major_version_number.$minor_version_number~g" TempZipDir/README.txt
sed -i "s~rm DynSuiteREPLACEME.zip~rm DynSuite_${major_version_number}_${minor_version_number}.zip~g" TempZipDir/InstallMecpro.sh

linesOfBashCode=`wc -l TempZipDir/*.sh | grep total`
linesOfPythonCode=`wc -l TempZipDir/*.py | grep total`
totalLinesOfCode=$((${linesOfPythonCode/ total}+${linesOfBashCode/ total}))

mv TempZipDir/InstallMecpro.sh $PWD

echo "Generating zip file"
zip -r "Mecpro_${major_version_number}_${minor_version_number}.zip" TempZipDir InstallMecpro.sh $> /dev/null

rm -rf TempZipDir
rm InstallMecpro.sh

echo "Lines of python code:   $linesOfPythonCode"
echo "Lines of bash code:   $linesOfBashCode"
echo "Total lines of code: $totalLinesOfCode total"

exit 0
