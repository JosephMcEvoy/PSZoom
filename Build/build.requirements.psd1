@{
    # Some defaults for all dependencies
    PSDependOptions = @{
        Target = '$ENV:USERPROFILE\Documents\PowerShell\Modules'
        AddToPath = $True
    }

    # Grab some modules without depending on PowerShellGet
    'psake' = @{
        DependencyType = 'PSGalleryNuget'
        Version = '4.9.0'
    }
    'PSDeploy' = @{
        Name = 'https://github.com/JosephMcEvoy/PSDeploy.git'
        DependencyType = 'Github'
        Version = 'Master'
    }
    'BuildHelpers' = @{
        DependencyType = 'PSGalleryNuget'
        Version = '2.0.16'
    }
    'Pester' = @{
        DependencyType = 'PSGalleryNuget'
        Version = '4.10.1'
    }
}