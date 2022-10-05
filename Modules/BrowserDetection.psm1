Function Get-Browser {
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

Function List-Browser {
    cls
    Write-Host " Browsers: `r`n"
    For($i = 0; $i -lt $Global:ActiveBrowsers.count; $i++) {
        Write-Host "   [$i]: $($Global:ActiveBrowsers[$i])"
    }
}