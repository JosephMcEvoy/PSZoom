# Load build environment helper
. "$PSScriptRoot\Private\Get-BuildEnvironment.ps1"
$BuildEnv = Get-BuildEnvironment

# Publish to gallery with restrictions
if ($BuildEnv.ModulePath -and
    $BuildEnv.BuildSystem -ne 'Unknown' -and
    $BuildEnv.BranchName -eq "master" -and
    $BuildEnv.CommitMessage -match '!deploy'
) {
    Deploy Module {
        By PSGalleryModule {
            FromSource $BuildEnv.ModulePath
            To PSGallery
            WithOptions @{
                ApiKey = $ENV:NugetApiKey
                SkipAutomaticTags = $True
            }
        }
    }
} else {
    "Skipping deployment: To deploy, ensure that...`n" +
    "`t* You are in a known build system (Current: $($BuildEnv.BuildSystem))`n" +
    "`t* You are committing to the master branch (Current: $($BuildEnv.BranchName)) `n" +
    "`t* Your commit message includes !deploy (Current: $($BuildEnv.CommitMessage))" |
        Write-Host
}

# Publish to AppVeyor if we're in AppVeyor
if ($BuildEnv.ModulePath -and $BuildEnv.BuildSystem -eq 'AppVeyor') {
    Deploy DeveloperBuild {
        By AppVeyorModule {
            FromSource $BuildEnv.ModulePath
            To AppVeyor
            WithOptions @{
                Version = $env:APPVEYOR_BUILD_VERSION
            }
        }
    }
}