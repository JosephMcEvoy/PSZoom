$Public  = @(Get-ChildItem -Path "$PSScriptRoot\Public\" -include '*.ps1' -recurse -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path "$PSScriptRoot\Private\" -include '*.ps1' -recurse -ErrorAction SilentlyContinue)

foreach ($ps1 in @($Public + $Private)) {
    try {
        . $ps1.fullname
    } catch {
        Write-Error -Message "Failed to import function $($ps1.fullname): $_"
    }
}

Export-ModuleMember -Function $Public.Basename