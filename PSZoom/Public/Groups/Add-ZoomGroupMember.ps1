<#

.SYNOPSIS
Add members to a under your account.

.DESCRIPTION
Add members to a under your account.
Prerequisite: Pro, Business, or Education account

.PARAMETER GroupId
The group ID.

.PARAMETER Email
Emails to be added to the group.

.PARAMETER Id
IDs to be added to the group.

.PARAMETER ApiKey
The Api Key.

.PARAMETER ApiSecret
The Api Secret.

.OUTPUTS
The Zoom response (an object). Example:
ids                    added_at
---                    --------
tKODqjp0S456QzjjcNQqVg 2019-08-28T22:39:51Z

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/groups/groupmemberscreate

.EXAMPLE
Add a single user to a single group.
$GroupId = ((Get-ZoomGroups) | where-object {$_ -eq 'Light Side'}).id
Add-ZoomGroupMembers -group $GroupID -Email okenobi@lightside.com, lskywalker@lightside.com

.EXAMPLE
Add users to a single group.
Get-ZoomGroups | where-object {$_ -eq 'Dark Side'} | Add-ZoomGroupMembers -email 'dvader@sith.org','dsidious@sith.org'

.EXAMPLE
Add a single user to all groups matching 'Side'.
Get-ZoomGroups | where-object {$_ -like '*Side*'} | Add-ZoomGroupMembers -email 'askywalker@theforce.com'

#>

function Add-ZoomGroupMember  {
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
       #Get Zoom Api Credentials


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

        if ($members.Count -gt 30) {
            throw 'Maximum amount of members that can be added at a time is 30.' #This limit is set by Zoom.
        }

        $requestBody.Add('members', $members)
        
        $requestBody = $requestBody | ConvertTo-Json

        foreach ($Id in $GroupId) {
            $Request = [System.UriBuilder]"https://api.zoom.us/v2/groups/$Id/members"
            if ($PScmdlet.ShouldProcess($members, 'Add')) {
                try {
                    $Response = Invoke-RestMethod -Uri $Request.Uri -Headers $headers -Body $RequestBody -Method POST
                } catch {
                    Write-Error -Message "$($_.exception.message)" -ErrorId $_.exception.code -Category InvalidOperation
                }

                if (-not $passthru) {
                    Write-Output $Response
                }
            }
        }

        if ($passthru) {
            Write-Output $GroupId
        }
    }
}