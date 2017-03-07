# ECLSyntaxChecker

  HPCC ECL syntax checker for Windows and Linux.

### Description

 This script can be useful if you are developing a project in HPCC: https://hpccsystems.com. 
  It allows you to perform a Syntax Check in all files as ECLIDE can only make syntax check of a single file.
  Script makes a Syntax Check on all *.ecl files in a given directory and subdirectories.
 
 Useful in these situations:
  - Windows PowerShell Script: Moving or refactoring files in your project. You can use it in conjuction with ECLIDE.
  - Linux BASH Script: Integrate it as one step of your CI build.

### Windows

 This is a powershell script with a .config file:
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

 This is a BASH script with four parameters:
  - RelativePathToCODEDirectory     --> Relative path from script to your ECL code.
  - RrelativePathToImportsDirectory --> Relative path from script to base path for ECL IMPORTS.
  - ExcludedDirectories             --> Top level directories under $CODEDirectory to be ignored.
  - IgnoreWarnings                  --> $true will make syntax check to ignore warnings.
 
 TODO
 - Resolve "horrible" workaround.
 - Allow to pass log file name as parameter.
 - Allow passing ECL Client Tools as parameter rather than relying in eclcc being in path.
