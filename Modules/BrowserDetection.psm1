Function Get-Browser {
    Write-Host " Checking for installed browsers."
    if (Test-Path -Path $Global:ChromePath) {
        Write-Host "   Google Chrome Detected."
        $Global:ActiveBrowsers += "Chrome"
    }

    if (Test-Path -Path $Global:EdgePath) {
        Write-Host "   Microsoft Edge Detected."
        $Global:ActiveBrowsers += "Edge"
    }
}

Function Select-Browser {
    cls
    $Selection = $Null

    Write-Host " Select your browser: `r`n"
    For($i = 0; $i -lt $Global:ActiveBrowsers.count; $i++) {
        Write-Host "   [$i]: $($Global:ActiveBrowsers[$i])"
    }

    While ( $Selection -notin 0..($Global:ActiveBrowsers.count -1)) {   
        $Selection = Read-Host "`r`n Browser Selection"
    } 

    return $Global:ActiveBrowsers[$Selection]
}

Function Get-BrowserAction {
    $Selection = $Null
    $Selections = @('l', 'q', 'a', 'c')

    While($Selection -notin $Selections) {
        Write-Host "`r`n Actions:`r`n"
        Write-Host "   a: audit browser"
        Write-Host "   c: clear screen"
        Write-Host "   l: list browsers"
        Write-Host "   q: quit`r`n"
        $Selection = Read-Host "Select action"

    }

    return $Selection

}

Function Get-AuditAction {
    $Selection = $Null
    $Selections = @('l', 'r', 's')

    While($Selection -notin $Selections) {
        Write-Host "`r`n Actions:`r`n"
        Write-Host "   l: list sites"
        Write-Host "   r: remote site"
        Write-Host "   s: stop audit"
        $Selection = Read-Host "`r`n Select action"

    }

    return $Selection

}

Function Get-Site {
    param( $BrowserPrefsJson )
    $Sites = @()
    $Exceptions = $BrowserPrefsJson.profile.content_settings.exceptions | Get-Member -MemberType NoteProperty | Select-Object Name
    ForEach($Exception in $Exceptions) {
        $Branch = $BrowserPrefsJson.profile.content_settings.exceptions.($Exception.Name)
        $BranchMembers = $Branch | Get-Member -MemberType NoteProperty | Select-Object Name 
        ForEach ($Member in $BranchMembers) {
            $Sites += $Member
        }
    }

    #$Sites = $Sites | Sort-Object -Property -Name | Get-Unique

    return $Sites

}

Function Show-Site {
    param( $BrowserPrefsJson )
    $Sites = Get-Site -BrowserPrefsJson $BrowserPrefsJson

    Write-Host "   Sites: `r`n"

    ForEach($Site in $Sites) {
        Write-Host "     - $($Site.name)"
    }

}

Function Remove-Site {
    param(
        $BrowserPrefsJson,
        $PrefsPath
     )
    $Sites = Get-Site -BrowserPrefsJson $BrowserPrefsJson

    Write-Host "   Sites: `r`n"

    For($i = 0; $i -le ($Sites.count); $i++) {
        Write-Host "     [$i] $($Sites[$i].name)"
    }

    $Selection = Read-Host "`r`n   Select Site"

    $SiteName = $Sites[$Selection].Name

    $Exceptions = $BrowserPrefsJson.profile.content_settings.exceptions | Get-Member -MemberType NoteProperty | Select-Object Name
    ForEach($Exception in $Exceptions) {
        $Branch = $BrowserPrefsJson.profile.content_settings.exceptions.($Exception.Name)
        $BranchMembers = $Branch | Get-Member | Select-Object Name
        if ( $BranchMembers.Name -eq $SiteName ) {
            "Cleaning $($Exception.name)"
            $Branch.PSObject.Properties.Remove($SiteName)
        }
    }

    $BrowserPrefsJson | ConvertTo-Json -Depth 100 -Compress `
        | Out-File $PrefsPath -NoNewline -Encoding utf8

}


Function Show-Browser {
    cls
    Write-Host " Browsers: `r`n"
    For($i = 0; $i -lt $Global:ActiveBrowsers.count; $i++) {
        Write-Host "   $($Global:ActiveBrowsers[$i])"
    }
}

Function Enter-Browser {
    $Audit = $True
    $Browser = Select-Browser
    $BrowserPrefs = $False
    $PrefsPath = $Null

    Write-Host " Starting browser audit."

    Switch($Browser) {
        "Chrome" { 
            $PrefsPath = $Global:ChromePath
        }
        "Edge" { 
            $PrefsPath = $Global:EdgePath
        }
    }

    
    $BrowserPrefs = Get-Content $PrefsPath

    if ($BrowserPrefs) {
        $BrowserPrefsJson = $BrowserPrefs | ConvertFrom-Json

        While ($Audit) {
            $Action = Get-AuditAction

            Switch ($Action) {
                'l' { Show-Site -BrowserPrefsJson $BrowserPrefsJson}
                'r' { Remove-Site -BrowserPrefsJson $BrowserPrefsJson -PrefsPath $PrefsPath}
                's' { $Audit = $False}
            }
        }
    } else {
        Write-Host "   Browser preferences not found. Stopping."
    }
}