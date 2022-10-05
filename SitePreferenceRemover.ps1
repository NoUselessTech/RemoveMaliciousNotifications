# ----------------------------
# Site Preference Remover 
# Author: NoUselessTech
# Date: October 4, 2022
# Version: 0.1
# ----------------------------
# Imports
Import-Module ./Modules/BrowserGlobals.psm1
Import-Module ./Modules/BrowserDetection.psm1

# Variables
$Run = $True

# Functions 

# Logic
cls

Get-Browser

While($Run) {

    $Action = Get-BrowserAction

    Switch($Action) {
        "a" { Enter-Browser; break; }
        "l" { Show-Browser; break; }
        "c" { Clear-Screen; break;}
        "q" { $Run = $False; break; }
    }

}

"Cleaning Up"
$Global:ActiveBrowsers = @()