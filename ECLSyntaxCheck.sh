#!/bin/bash
# Script author       : Oscar Foley
# Script Description  : This script makes a syntax check of all ecl code
# Version             : 1.0
# Notes

# Check dependencies
which eclcc >/dev/null 2>&1 || { echo >&2 "Script requires eclcc from HPCC client tools but it's not installed (https://hpccsystems.com/download/developer-tools/client-tools).  Aborting."; exit 1; }

# Parameters
RelativePathToCODEDirectory=$1 #"../../HPCC"
RelativePathToIMPORTSDirectory=$2 # "../../HPCC"
ExcludedDirectories=$3
IgnoreWarnings=$4

function_ArrayContainsElement() 
{
  local e
  for e in "${@:2}"; 
  do 
    [[ "$e" == "$1" ]] && return 0; 
  done
  return 1
}

function_syntaxCheckFileName()
{
	pFileName=$1
  pBASEImportsDirectory=$2
  pIgnoreWarnings=$3
  
  errorCount=0
  result1=$(eclcc -legacy -syntax -I="$pBASEImportsDirectory" "$pFileName" 2>&1)

  if [[ -n $result1 ]];
  then
    mapfile -t arr <<< "$result1"
    count=${#arr[@]}
    for ((i=0; i<=($count - 2); i++)); # Usually for would iterate to $count - 1 but I am not interested in the last line "x errors, y warnings" so I iterate to $count -2
    do
      resultLine=${arr[i]}
      if [[ $pIgnoreWarnings = true ]]; then
        if [[ ! "${resultLine}" == *warning* ]]; then
           echo " $resultLine"
           errorCount=$((errorCount+1))
        fi      
      else 
        echo " $resultLine"
        errorCount=$((errorCount+1))
      fi
    done
  fi
  echo "$errorCount" >> "$tmpFileName"
  return $errorCount
}

function_SyntaxCheckAllFilesInDirectory()
{
  pDirectory=$1
  pBASEImportsDirectory=$2
  pIgnoreWarnings=$3
  
  tmpTotalErrors=0
  result=0
  echo "Checking directory: $pDirectory"
  find "$pDirectory" -name '*.ecl' -print0 | while read -d $'\0' file
  do 
    function_syntaxCheckFileName "$file" "$pBASEImportsDirectory" $pIgnoreWarnings
    result=$?
    tmpTotalErrors=$((tmpTotalErrors + result)) 
  done  
  return $tmpTotalErrors 
}

# MAIN
sourceDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CODEDirectoryFullPath=$( readlink -f "$sourceDir/$RelativePathToCODEDirectory" )
BASEImportsDirectory=$( readlink -f "$sourceDir/$RelativePathToIMPORTSDirectory" )
tmpFileName="./tmpSyntaxCheckResult.tmp"
echo "Script source directory=$sourceDir"
echo "Syntax check *.ecl files in directory= $CODEDirectoryFullPath"
echo "Base directory for imports= $BASEImportsDirectory"
echo "HPCC client tools version= $( eclcc --version )"

if [[ $# -eq 0 ]]; then
    echo "ERROR: No arguments supplied"
    exit 255
fi

echo "Starting SyntaxCheck..."
rm $tmpFileName -f 2>/dev/null

IFS=', ' read -r -a arrayExcludedDirectories <<< "$ExcludedDirectories"
totalErrors=0
find "$CODEDirectoryFullPath" -mindepth 1 -maxdepth 1 -type d -print0  | while read -d '' -r elementString; 
do 
  if function_ArrayContainsElement $(basename "$elementString") "${arrayExcludedDirectories[@]}";  # Exclude directories that are in exclusion list
  then
    echo "-- Excluded $elementString"
  else
    function_SyntaxCheckAllFilesInDirectory "$elementString" "$BASEImportsDirectory" $IgnoreWarnings
    resultErrors=$?
    totalErrors=$((totalErrors + resultErrors))
  fi
done
# totaLErrors value is lost due to a bug in bash. Shopt solution as explained here http://mywiki.wooledge.org/BashFAQ/024 causes a Segmentation Fault :-(
# As a (horrible) workaround I write number of errors to a tmp file ($tmpFileName) and add the end I add them.
sum=0; while read num ; do sum=$(($sum + $num)); done < $tmpFileName ;
totalErrorsFromFile=$sum
echo "SyntaxCheck finished. Errors detected = $totalErrorsFromFile"
exit $totalErrorsFromFile