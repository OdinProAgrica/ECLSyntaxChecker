# ---------------------  VARIABLES (app.config)  ---------------------------------------------------------------------
$relativePathToCODEDirectory         = ".\..\..\HPCC"        # Relative path from script to ECL code
$relativePathToImportsDirectory      = ".\..\..\HPCC"        # Relative path from script to base path for ECL IMPORTS
$logfile                             = "EclSyntaxCheck.log"  # 
$ignoreWarnings                      = $true                 # $true will make syntax check to ignore warnings
$excludedDirectories                 = "BWR", "TEST"         # Directories under $CODEDirectory to be ignored
$eclClientTools                      = "C:\Program Files (x86)\HPCCSystems\5.6.4\clienttools\bin"