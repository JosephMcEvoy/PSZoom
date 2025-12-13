# Build/Private/Set-PSZoomModuleFunctions.ps1
function Set-PSZoomModuleFunctions {
    <#
    .SYNOPSIS
        Updates the FunctionsToExport in a module manifest.
    .DESCRIPTION
        Scans Public folder for function files and updates the manifest.
        Replaces BuildHelpers Set-ModuleFunctions.
    .PARAMETER ManifestPath
        Path to the module manifest (.psd1) file.
    .PARAMETER PublicPath
        Path to the Public functions folder.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ManifestPath,

        [Parameter()]
        [string]$PublicPath
    )

    if (-not $PublicPath) {
        $PublicPath = Join-Path (Split-Path $ManifestPath -Parent) 'Public'
    }

    # Get all public function names from .ps1 files
    $functions = Get-ChildItem -Path $PublicPath -Filter '*.ps1' -Recurse |
        ForEach-Object {
            $_.BaseName
        } |
        Sort-Object -Unique

    if ($functions.Count -eq 0) {
        Write-Warning "No functions found in $PublicPath"
        return
    }

    # Update manifest
    Update-ModuleManifest -Path $ManifestPath -FunctionsToExport $functions
    Write-Verbose "Updated $ManifestPath with $($functions.Count) functions"
}
