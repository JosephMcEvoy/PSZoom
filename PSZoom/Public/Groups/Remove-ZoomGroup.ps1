<#

.SYNOPSIS
Delete a group under your account.
.DESCRIPTION
Delete a group under your account.
Prerequisite: Pro, Business, or Education account.
.PARAMETER GroupId
The group ID.
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
.OUTPUTS
No output.
.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/groups/groupdelete
.EXAMPLE
Remove-ZoomGroup
.EXAMPLE
Remove a user from all groups that include the word Training in the name.
(Get-ZoomGroups).groups | where-object {$_ -like '*Training*'} | Remove-ZoomGroup

#>

function Remove-ZoomGroup {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [Alias('Remove-ZoomGroups')]
    param (
        [Parameter(
            Mandatory = $True, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True, 
            Position = 0
        )]
        [Alias('group_id', 'group', 'id', 'groupids')]
        [string[]]$GroupId,
        
        [string]$ApiKey,
        
        [string]$ApiSecret
    )

    begin {
        #Get Zoom Api Credentials
        $Credentials = Get-ZoomApiCredentials -ZoomApiKey $ApiKey -ZoomApiSecret $ApiSecret
        $ApiKey = $Credentials.ApiKey
        $ApiSecret = $Credentials.ApiSecret

        #Generate Headers and JWT (JSON Web Token)
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {

        foreach ($Id in $GroupID) {
            #Need to add API rate limiting
            $Request = [System.UriBuilder]"https://api.zoom.us/v2/groups/$Id"
            if ($PSCmdlet.ShouldProcess($Id, "Remove")) {
                try {
                    $Response = Invoke-RestMethod -Uri $Request.Uri -Headers $headers -Method DELETE
                }
                catch {
                    Write-Error -Message "$($_.exception.message)" -ErrorId $_.exception.code -Category InvalidOperation
                }
                Write-Verbose "Group $Id deleted."
                Write-Output $Response
            }
        }
    }
}