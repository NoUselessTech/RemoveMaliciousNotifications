$Bad = Read-Host "Insert Baddie url" 
$ChromePrefs = Get-Content "$Env:UserProfile\AppData\Local\Google\Chrome\User Data\Default\Preferences"
$ChromePrefsJson = $ChromePrefs | ConvertFrom-Json
$Exceptions = $ChromePrefsJson.profile.content_settings.exceptions | Get-Member -MemberType NoteProperty | Select-Object Name
ForEach($Exception in $Exceptions) {
    $Branch = $ChromePrefsJson.profile.content_settings.exceptions.($Exception.Name)
    $BranchMembers = $Branch | Get-Member | Select-Object Name
    if ( $BranchMembers.Name -like "*$($Bad)*" ) {
        "Cleaning $($Exception.name)"
        $BranchMember = $BranchMembers | Where-Object {$_.name -like "*$($Bad)*"}
        $Branch.PSObject.Properties.Remove($BranchMember.name)
    }
}
$ChromePrefsJson | ConvertTo-Json -Depth 100 -Compress `
    | Out-File "$env:UserProfile\AppData\Local\Google\Chrome\User Data\Default\Preferences" `
    -NoNewline -Encoding utf8
