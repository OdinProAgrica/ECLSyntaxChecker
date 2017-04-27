# Script author      	: Oscar Foley
# Script Description 	: This script makes a syntax check of all ecl code
# Notes
$Version				= "1.2"

function Write-LogMessage($message, $logfile, $isError = $false)
{
    if ($isError)
    {
        $textColour = 'red'
    }
    else
    {
        $textColour = 'white'
    }
    
    Write-Host $message -ForegroundColor $textColour
    Add-Content $logfile $message
}

function DetectPowershellVersion($minVersion=3, $logFile)
{
    # Check Powershell version
    $PSVersion = $PSVersionTable.PSVersion
    Write-LogMessage "Detected PowerShell version: $PSVersion" $logFile
    if ( ([int]$PSVersion.Major) -lt $minVersion)
    {
        throw "ERROR. Script needs Powershell $minVersion or higher."
    }
}

function DetectECLCCVersion($logFile)
{
    $cmdName =  "$eclClientTools\eclcc.exe"
    if (Get-Command $cmdName -errorAction SilentlyContinue)
    {
        Write-LogMessage "$cmdName exists" $logFile
    }
    else
    {
        throw "Cannot find eclcc $cmdName. Please install correct version from https://hpccsystems.com/download/developer-tools/client-tools"
    }

    if (!(Get-Command "eclcc" -errorAction SilentlyContinue))
    {
        $env:Path += ";$eclClientTools"
    }
}

function PrintCompilingErrors($fileName, $stringList, $ignoreWarnings = $false, $logfile)
{
    foreach ($element in $stringlist)
    {
        if ($element.StartsWith($fileName))
        {
            if ($ignoreWarnings)
            {
                if (!$element.Contains(': warning C'))
                {   
                    Write-LogMessage " $element" $logfile $true
                }
            }
            else
            {
                Write-LogMessage " $element" $logfile $true
            }
        }
    }
}

function SyntaxCheckAllFilesInDirectory($BASEDirectory, $BASEImportsDirectory, $ignoreWarnings, $logfile)
{
    $list = Get-ChildItem -Path $BASEDirectory -Recurse -Filter "*.ecl"
    foreach ($item in $list)
    {
        $fullName = "$($item.DirectoryName)\$($item.Name)"
        $directory = $($item.DirectoryName)
        $cmdOuput = cmd /c eclcc -legacy -syntax -I="$BASEImportsDirectory" $fullName '2>&1' 
        
        PrintCompilingErrors $fullName $cmdOuput $ignoreWarnings $logfile 
    }
}

# Imports
$scriptsDirectory = Split-Path $MyInvocation.MyCommand.Definition -parent
. $(Join-Path $scriptsDirectory "ECLSyntaxCheck.config.ps1") # Load app.config
cd $scriptsDirectory

# MAIN
try
{
    $startTime = Get-Date
    cls
    Write-LogMessage "ECLSyntaxChecker version $Version started ($startTime)" $logfile
    Remove-Item -Force "$scriptsDirectory\$logFile" -ErrorAction SilentlyContinue
    Write-LogMessage "Initializing log file: $scriptsDirectory\$logFile" $logFile
    
    DetectPowershellVersion 3 $logfile
    Write-LogMessage "Configuration (from ECLSyntaxCheck.config.ps1)" $logfile
    Write-LogMessage "- Relative Path to code directory    : $relativePathToCODEDirectory" $logfile
    Write-LogMessage "- Relative Path to imports directory : $relativePathToImportsDirectory" $logfile
    Write-LogMessage "- Log file name                      : $logfile" $logfile
    Write-LogMessage "- Ignore Warnings                    : $ignoreWarnings" $logfile
    Write-LogMessage "- Exclude Directories                : $excludedDirectories" $logfile
    Write-LogMessage "- HPCC Client Tools path             : $eclClientTools" $logfile
    Write-LogMessage "Starting ECL SyntaxCheck..." $logfile

    DetectECLCCVersion $logfile
    $CODEDirectory    = (Get-Item -Path $relativePathToCODEDirectory -Verbose).FullName + '\'
    $ImportsDirectory = (Get-Item -Path $relativePathToImportsDirectory -Verbose).FullName
    Write-LogMessage "Absolute Path to code directory    : $CODEDirectory" $logfile
    Write-LogMessage "Absolute Path to imports directory : $ImportsDirectory" $logfile
    
    Write-LogMessage "Starting ECL Syntax check in all *.ecl files in $CODEDirectory" $logfile
    
    Write-LogMessage "Checking directories from $CODEDirectory" $logfile
    $list = Get-ChildItem -Path $CODEDirectory -Directory
    
    foreach ($dir in $list)
    {
        if ($excludedDirectories.Contains($dir.Name))
        {
            Write-LogMessage " -- excluded - $($dir.FullName)" $logfile
        }
        else
        {
            Write-LogMessage " $($dir.FullName)" $logfile
            SyntaxCheckAllFilesInDirectory $dir.FullName $ImportsDirectory $ignoreWarnings $logfile
        }
    
    }

    #END
    $endTime = Get-Date
    Write-LogMessage "Finished ECL SyntaxCheck ($endTime)" $logfile
    $elapsedTime = new-timespan $startTime $endTime 
    Write-LogMessage "Script time = $elapsedTime" $logfile
    $exitCode = 0
}
Catch 
{
    $errorMessage = $_.Exception
    Write-LogMessage $errorMessage $logfile
    $exitCode = 1
}
finally
{
    exit $exitCode
}