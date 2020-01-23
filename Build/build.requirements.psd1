@{
    # Some defaults for all dependencies
    PSDependOptions = @{
        Target = '$ENV:USERPROFILE\Documents\PowerShell\Modules'
        AddToPath = $True
    }

    # Grab some modules without depending on PowerShellGet
    'psake' = @{
        DependencyType = 'PSGalleryNuget'
    }
    'PSDeploy' = @{
        DependencyType = 'PSGalleryNuget'
        Version = '1.0.3'
    }
    'BuildHelpers' = @{
        DependencyType = 'PSGalleryNuget'
        Version = '2.0.10'
    }
    'Pester' = @{
        DependencyType = 'PSGalleryNuget'
        Version = '4.1.0'
    }
}