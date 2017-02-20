# ECLSyntaxChecker

  HPCC ECL syntax checker for Windows and Linux.

### Description

 This script can be useful if you are developing a project in HPCC: https://hpccsystems.com
 
 It allows you to perform a Syntax Check in all files as ECLIDE can only make syntax check of a single file.
 
 Script makes a Syntax Check on all *.ecl files in a given directory and subdirectories.
 
 Useful in these situations:
  - Moving or refactoring files in your project.
  - As part of your CI build.

### Windows

 This is a simple powershell script with a .config file:
  - $relativePathToCODEDirectory    --> Relative path from script to your ECL code.
  - $relativePathToImportsDirectory --> Relative path from script to base path for ECL IMPORTS.
  - $logfile                        --> Name of log file (i.e: "EclSyntaxCheck.log").
  - $ignoreWarnings                 --> $true will make syntax check to ignore warnings.
  - $excludedDirectories            --> Top level directories under $CODEDirectory to be ignored.
  - $eclClientTools                 --> Path to your HPCC Client Tools. (i.e: "C:\Program Files (x86)\HPCCSystems\5.6.4\clienttools\bin")
 
 It requires PowerShell 3.0 and HPCC Client Tools.
 
 TODO
 - Add parameters to override config file.
 - Improve excluded directories to allow a list of directories at any level.

### Linux

 To be uploaded soon...