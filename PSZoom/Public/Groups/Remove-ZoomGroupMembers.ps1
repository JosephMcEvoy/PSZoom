<#

.SYNOPSIS
Delete members from groups under your account.
.DESCRIPTION
Delete members from groups under your account.
The default Zoom Api being used here supports deleting one member from one group.
This function expands off that, allowing multiple members to be deleted from multiple groups.
Prerequisite: Pro, Business, or Education account.
.PARAMETER GroupId
This is the ID of the group. Not to be confused with MemberId. This also has the alias 'id'. 
This is for better pipeline support with other functions. Other aliases include 'group_id' and 'group'.
.PARAMETER MemberIds
This is the ID of the member. Not to be confused with the GroupId. MemberId is an alias.
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
.OUTPUTS
"Group member deleted."
.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/groups/groupmembersdelete
.EXAMPLE
Remove a user from all groups that include the word Training in the name.
(Get-ZoomGroups).groups | where-object {$_ -like '*Training*'} | Remove-ZoomGroupMembers -memberids ((get-zoomspecificuser 'lskywalker@swars.com').id)

#>

function Remove-ZoomGroupMembers {
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact='Medium')]
    param (
        [Parameter(
            Mandatory = $True, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True, 
            Position = 0
        )]
        [Alias('group_id', 'group', 'id')]
        [string[]]$GroupIds,

        [Parameter(
            ValueFromPipelineByPropertyName = $True, 
            Position = 1
        )]
        [Alias('memberid')]
        [string[]]$MemberIds,
        
        [string]$ApiKey,
        
        [string]$ApiSecret
    )

    begin {
        #Generate Headers and JWT (JSON Web Token)
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        foreach ($GroupId in $GroupIDs) {
            #Need to add API rate limiting
            foreach ($MemberId in $MemberIds) {
                $Request = [System.UriBuilder]"https://api.zoom.us/v2/groups/$GroupId/members/$MemberId"
                
                if ($PScmdlet.ShouldProcess) {
                    try {
                        $response = Invoke-RestMethod -Uri $request.Uri -Headers $headers -Method DELETE
                    } catch {
                        Write-Error -Message "$($_.Exception.Message)" -ErrorId $_.Exception.Code -Category InvalidOperation
                    } finally {
                        Write-Verbose "Removed $MemberId from $GroupId."
                        Write-Output $response
                    }
                }
            }
        }
    }
}