    <#
    .SYNOPSIS
        Bootstrap PSDepend

    .DESCRIPTION
        Bootstrap PSDepend

        Why? No reliance on PowerShellGallery

          * Downloads nuget to your ~\ home directory
          * Creates $Path (and full path to it)
          * Downloads module to $Path\PSDepend
          * Moves nuget.exe to $Path\PSDepend (skips nuget bootstrap on initial PSDepend import)

    .PARAMETER Path
        Module path to install PSDepend

        Defaults to Profile\Documents\WindowsPowerShell\Modules

    .EXAMPLE
        .\Install-PSDepend.ps1 -Path C:\Modules

        # Installs to C:\Modules\PSDepend
    #>
    Install-PSDepend