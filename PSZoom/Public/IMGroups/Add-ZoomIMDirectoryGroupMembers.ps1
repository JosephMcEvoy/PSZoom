<#

.SYNOPSIS
Add members to an under an account.

.DESCRIPTION
Add members to an under an account.

.PARAMETER GroupId
The group ID.

.PARAMETER Email
Emails to be added to the group.

.PARAMETER MemberId
IDs to be added to the group.

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
        [Alias('group_id', 'group', 'groups', 'groupids')]
        [string[]]$GroupId,

        [Parameter(
            ValueFromPipelineByPropertyName = $True, 
            Position = 1
        )]
        [Alias('MemberEmail', 'emails', 'emailaddress', 'emailaddresses', 'memberemails')]
        [string[]]$Email,

        [Parameter(
            Position = 2
        )]
        [Alias('memberids')]
        [string[]]$MemberId,

        [switch]$Passthru
    )

    process {
        $requestBody = @{}

        $members = New-Object System.Collections.Generic.List[System.Object]

        if (-not $Email -and -not $MemberId) {
            throw 'At least one email or ID is required.'
        }

        if ($PSBoundParameters.ContainsKey('Email')) {
            $MemberEmail | ForEach-Object {
                $members.Add(@{email = $_})
            }
        }

        if ($PSBoundParameters.ContainsKey('MemberId')) {
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
            $request = [System.UriBuilder]"https://api.$ZoomURI/v2/im/groups/$Id/members"
            if ($PScmdlet.ShouldProcess($members, 'Add')) {
                $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $RequestBody -Method POST

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
