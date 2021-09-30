<#

.SYNOPSIS
Add members to an under an account.

.DESCRIPTION
Add members to an under an account.

.PARAMETER GroupId
The group ID.

.PARAMETER Email
Emails to be added to the group.

.PARAMETER Id
IDs to be added to the group.

.PARAMETER ApiKey
The API Key.

.PARAMETER ApiSecret
The API Secret.

#>

function Add-ZoomIMDirectoryGroupMembers  {
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact='Low')]
    param (
        [Parameter(
            Mandatory = $True, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True, 
            Position = 0
        )]
        [Alias('group_id', 'group', 'groups', 'id', 'groupids')]
        [string[]]$GroupId,

        [Parameter(
            ValueFromPipelineByPropertyName = $True, 
            Position = 1
        )]
        [Alias('email', 'emails', 'emailaddress', 'emailaddresses', 'memberemails')]
        [string[]]$MemberEmail,

        [Parameter(
            Position = 2
        )]
        [Alias('memberids')]
        [string[]]$MemberId,
        
        [string]$ApiKey,
        
        [string]$ApiSecret,

        [switch]$Passthru
    )

    begin {
        #Generate Headers and JWT (JSON Web Token)
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        $requestBody = @{}

        $members = New-Object System.Collections.Generic.List[System.Object]

        if (-not $MemberEmail -and -not $MemberId) {
            throw 'At least one email or ID is required.'
        }

        if ($PSBoundParameters.ContainsKey('MemberEmail')) {
            $MemberEmail | ForEach-Object {
                $members.Add(@{email = $_})
            }
        }

        if ($PSBoundParameters.ContainsKey('MemberIds')) {
            $MemberId | ForEach-Object {
                $members.Add(@{id = $_})
            }
        }

        if ($members.Count -gt 10) {
            throw 'Maximum amount of members that can be added at a time is 10.' #This limit is set by Zoom.
        }

        $requestBody.Add('members', $members)
        
        $requestBody = $requestBody | ConvertTo-Json

        foreach ($Id in $GroupId) {
            $request = [System.UriBuilder]"https://api.zoom.us/v2/im/groups/$Id/members"
            if ($PScmdlet.ShouldProcess($members, 'Add')) {
                $response = Invoke-ZoomRestMethod -Uri $request.Uri -Headers ([ref]$Headers) -Body $RequestBody -Method POST -ApiKey $ApiKey -ApiSecret $ApiSecret

                if (-not $passthru) {
                    Write-Output $response
                }
            }
        }

        if ($passthru) {
            Write-Output $GroupId
        }
    }
}
