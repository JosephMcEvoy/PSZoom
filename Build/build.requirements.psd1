@{
    # Some defaults for all dependencies
    PSDependOptions = @{
        Target = '$ENV:USERPROFILE\Documents\PowerShell\Modules'
        AddToPath = $True
    }

    # Grab modules without depending on PowerShellGet
    'psake' = @{
        DependencyType = 'PSGalleryNuget'
        Version = '4.9.0'
    }
    
    'PSDeploy' = @{
        DependencyType = 'PSGalleryNuget'
        Version = '1.0.5'
    }
    
    'BuildHelpers' = @{
        DependencyType = 'PSGalleryNuget'
        Version = '2.0.16'
    }
    
    'Pester' = @{
        DependencyType = 'PSGalleryNuget'
        Version = '5.6.1'
    }
}
