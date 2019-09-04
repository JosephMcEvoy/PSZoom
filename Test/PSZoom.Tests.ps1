$PSVersion = $PSVersionTable.PSVersion.Major
$ModuleName = $ENV:BHProjectName
$ModulePath = Join-Path $ENV:BHProjectPath $ModuleName
$TestUri = 'TestUri'
$TestToken = 'TestToken'
$TestArchive = 'TestArchive'
$TestProxy = 'TestProxy'

# Verbose output for non-master builds on appveyor
# Handy for troubleshooting.
# Splat @Verbose against commands as needed (here or in pester tests)

$Verbose = @{}
if($ENV:BHBranchName -notlike "master" -or $env:BHCommitMessage -match "!verbose") {
    $Verbose.add("Verbose", $True)
}

Import-Module $ModulePath -Force

#Import private functions
$Private = @(Get-ChildItem -Path "$ModulePath\Private\" -include '*.ps1' -recurse -ErrorAction SilentlyContinue)

foreach ($file in $Private) {
    try {
        . $file.fullname
    } catch {
        Write-Error -Message "Failed to import function $($ps1.fullname): $_"
    }
}



$Module = Get-Module $ModuleName
$Commands = $Module.ExportedCommands.Keys

function ShowMockInfo($functionName, [String[]] $params) {
    if ($ShowMockData)
    {
        Write-Host " Mocked $functionName" -ForegroundColor Cyan
        foreach ($p in $params) {
            Write-Host " [$p] $(Get-Variable -Name $p -ValueOnly)" -ForegroundColor Cyan
        }
    }
}

InModuleScope $ModuleName {
    Describe "PSZoom General Tests" {
        It 'Should be the correct name' {
            $Module.Name | Should Be $ModuleName
        }
    }
}
<#
        It 'Should generate a JWT correctly' {
            $token = (New-JWT -Algorithm 'HS256' -type 'JWT' -Issuer 123 -SecretKey 456 -ValidforSeconds 30)
            $parsedToken = (Parse-JWTtoken -Token $token)
            $(parsedToken.alg) | Should -Be 'HS256'
            $parsedToken.typ | Should -Be 'JWT'
            $parsedToken.iss | Should -Be '123'
            $parsedToken.exp | Should -Not -BeNullOrEmpty
        }

        It 'Should create the correct headers' {
            $headers = New-ZoomHeaders -ApiKey 123 -ApiSecret 456
            $headers.'content-type' | Should -Be 'application/json'
            $headers.authorization  | Should -BeLike '*bearer*'
        }
    }
}
#>

Describe "PSZoom Meeting Tests" {
    Context 'Strict mode' {
        Set-StrictMode -Version 'latest'

        It 'Should load' {
            $MeetingCommands = @(
                'Add-ZoomMeetingRegistrant',
                'Get-ZoomEndedMeetingInstances',
                'Get-ZoomMeeting',
                'Get-ZoomMeetingInvitation',
                'Get-ZoomMeetingPoll',
                'Get-ZoomMeetingRegistrants',
                'Get-ZoomMeetingsFromUser',
                'Get-ZoomPastMeetingDetails',
                'Get-ZoomPastMeetingParticipants',
                'Get-ZoomRegistrationQuestions',
                'Get-ZoomTelephoneReports',
                'New-ZoomMeetingPoll',
                'Remove-ZoomMeeting',
                'Remove-ZoomMeetingPoll',
                'Update-MeetingStatus',
                'Update-ZoomMeeting',
                'Update-ZoomMeetingLiveStream',
                'Update-ZoomMeetingPoll',
                'Update-ZoomMeetingRegistrantStatus'
            )
            
            $MeetingCommands | ForEach-Object {
                $Commands -contains $_ | Should Be $true
            }
        }
    }
}

Describe "PSZoom User Tests" {
    Context 'Strict mode' {
        Set-StrictMode -Version 'latest'

        It 'Should load' {
            $UserCommands = @(
                'Get-ZoomRegistrationQuestions',
                'Get-ZoomSpecificUser',
                'Get-ZoomTelephoneReports',
                'Get-ZoomUserAssistants',
                'Get-ZoomUserEmailStatus',
                'Get-ZoomUserPermissions',
                'Get-ZoomUsers',
                'Get-ZoomUserSchedulers',
                'Get-ZoomUserSettings',
                'Get-ZoomUserToken',
                'New-ZoomUser',
                'Remove-ZoomSpecificUserAssistant',
                'Remove-ZoomSpecificUserScheduler',
                'Remove-ZoomUser',
                'Remove-ZoomUserAssistants',
                'Remove-ZoomUserSchedulers',
                'Revoke-ZoomUserSsoToken',
                'Update-ZoomProfilePicture',
                'Update-ZoomUser',
                'Update-ZoomUserEmail',
                'Update-ZoomUserpassword',
                'Update-ZoomUserSettings',
                'Update-ZoomUserStatus'
            )
            
            $UserCommands | ForEach-Object {
                $Commands -contains $_ | Should Be $true
            }
        }
    }
}

Describe "PSZoom Group Tests" {
    Context 'Strict mode' {
        Set-StrictMode -Version 'latest'

        Mock Invoke-RestMethod {
            Write-Output $Body,$Uri,$Method
        }

        $GroupCommands = @(
                'Add-ZoomGroupMember',
                'Get-ZoomGroupLockSettings',
                'Get-ZoomGroups',
                'Get-ZoomGroupSettings',
                'Get-ZoomSpecificGroup',
                'New-ZoomGroup',
                'Remove-ZoomGroup',
                'Remove-ZoomGroupMembers',
                'Update-ZoomGroup',
                'Update-ZoomGroupLockSettings',
                'Update-ZoomGroupSettings'
        )

        It 'Should load' {
            $GroupCommands | ForEach-Object {
                $Commands -contains $_ | Should Be $True
            }
        }
    }
}

Describe "New-ZoomGroup" {
    Mock Invoke-RestMethod {
        Write-Output @{
            Body = $Body
            Uri = $Uri
            Method = $Method
        }
    }
    
    $CreateGroupSchema = '{
        "type": "object",
        "properties": {
          "name": {
            "type": "string",
            "description": "Group name."
          }
        }
      }'

    It "Should validate against the schema" {
       Test-Json -Json (New-ZoomGroup -Name 'TestGroupName' -ApiKey 123 -ApiSecret 456).Body -Schema $CreateGroupSchema | Should Be $True
    }
}

<#
Mock Invoke-RestMethod {
    ShowMockInfo 'Invoke-RestMethod' -Params 'Uri', 'Headers', 'Body', 'Method'
}

Describe "New-ZoomUser Tests" {
    It "Calls the correct URI, Method, and Body" {
        $y = New-ZoomUser -Action 'ssoCreate' -Email 'kren@darkside.com' -Type 'Pro' -FirstName 'Kylo' -LastName 'Ren' -ApiKey '123' -ApiSecret '456'
        Assert-MockCalled -CommandName Invoke-WebRequest -ParameterFilter {`
            $Uri -eq 'https://api.zoom.us/v2/users' -and`
            $Method -eq 'Post' -and`
            $Body.
        } -Scope It
    }
}
#>