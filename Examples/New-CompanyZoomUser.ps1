<#
.SYNOPSIS
Creates a Zoom user given inputs.

.DESCRIPTION
Creates a Zoom user given inputs. Can also create a Zoom user given only the AD account. This is an example script 
and needs to be customized for your business needs. The script maps AD account properties to properties in Zoom. By 
default it maps things such as phone number to Zoom PMI, office location to Zoom group (there's a switch statement 
that should be modified if this is to be used), and other mappings. It also adds 'admin@company.com' as a scheduling 
assistant by default.

.PARAMETER Action
Specify how to create the new user.

.PARAMETER Email
User email address.

.PARAMETER Type
Basic (1)
Pro (2)
Corp (3)

.PARAMETER FirstName
User's first namee: cannot contain more than 5 Chinese words.

.PARAMETER LastName
User's last name: cannot contain more than 5 Chinese words.

.PARAMETER Password
User password. Only used for the "autoCreate" function. The password has to have a minimum of 8 characters and maximum of 32 characters. 
It must have at least one letter (a, b, c..), at least one number (1, 2, 3...) and include both uppercase and lowercase letters. 
It should not contain only one identical character repeatedly ('11111111' or 'aaaaaaaa') and it cannot contain consecutive characters ('12345678' or 'abcdefgh').

.PARAMETER GroupId
The name of the group the user will be added to.

.PARAMETER Pmi
Personal Meeting ID, long, length must be 10.

.PARAMETER UsePmi
Use Personal Meeting ID for instant meetings.

.PARAMETER Language
Language.

.PARAMETER Dept
Department for user profile: use for report.

.PARAMETER VanityName
Personal meeting room name.

.PARAMETER HostKey
Host key. It should be a 6-10 digit number.

.PARAMETER CMSUserId
Kaltura user ID.

.PARAMETER SchedulingAssistant
The Zoom user that will have scheduling permissions.

.PARAMETER RequirePasswordForSchedulingNewMeetings
Require a passcode for meetings which have already been scheduled.

.PARAMETER RequirePasswordForInstantMeetings
Require a passcode for instant meetings. If you use PMI for your instant meetings, this option will be disabled. 
This setting is always enabled for free accounts and Pro accounts with a single host and cannot be modified for 
these accounts.

.PARAMETER RequirePasswordForPmiMeetings
Require a passcode for Personal Meeting ID (PMI). This setting is always enabled for free accounts and Pro accounts 
with a single host and cannot be modified for these accounts.

.PARAMETER EmbedPasswordInJoinLink
If the value is set to `true`, the meeting passcode will be encrypted and included in the join meeting link to allow 
participants to join with just one click without having to enter the passcode.

.PARAMETER ApiKey
The API key.

.PARAMETER ApiSecret
THe API secret.

.OUTPUTS
No output. Can use Passthru switch to pass UserId to output.

.EXAMPLE
New-CompanyZoomUser lskywalker

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/users/usercreate

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/users/userupdate

#>

#requires -module PSZoom, ActiveDirectory

function New-CompanyZoomUser {
    [CmdletBinding(DefaultParameterSetName = 'AdAccount')]
    param (
        [Parameter(
            Mandatory = $True, 
            ParameterSetName = 'AdAccount',
            ValueFromPipeline = $True,
            Position = 0
        )]
        [ValidateLength(1, 128)]
        [Alias('identity')]
        [string]$AdAccount,

        [Parameter(
            Mandatory = $True,
            ParameterSetName = 'Manual',
            ValueFromPipelineByPropertyName = $True
        )]
        [ValidateLength(1, 128)]
        [Alias('EmailAddress')]
        [string]$Email,

        [Parameter(
            ParameterSetName = 'Manual', 
            ValueFromPipelineByPropertyName = $True
        )]
        [ValidateSet('create', 'autoCreate', 'custCreate', 'ssoCreate')]
        [string]$Action = 'ssoCreate',
            
        [Parameter(
            ParameterSetName = 'Manual', 
            ValueFromPipelineByPropertyName = $True
        )]
        [ValidateSet('Basic', 'Pro', 'Corp', 1, 2, 3)]
        [string]$Type = 'Pro',
            
        [Parameter(
            Mandatory = $True, 
            ParameterSetName = 'Manual', 
            ValueFromPipelineByPropertyName = $True
        )]
        [ValidateLength(1, 64)]
        [Alias('first_name', 'givenname')]
        [string]$FirstName,
            
        [Parameter(
            Mandatory = $True, 
            ParameterSetName = 'Manual', 
            ValueFromPipelineByPropertyName = $True
        )]
        [ValidateLength(1, 64)]
        [Alias('last_name', 'surname')]
        [string]$LastName,

        [Parameter(
            ParameterSetName = 'Manual', 
            ValueFromPipelineByPropertyName = $True
        )]
        [ValidateRange(1000000000, 9999999999)]
        [Alias('OfficePhone')]$Pmi,

        [Parameter(
            ParameterSetName = 'Manual', 
            ValueFromPipelineByPropertyName = $True
        )]
        [bool]$UsePmi,

            
        [Parameter(
            ParameterSetName = 'Manual', 
            ValueFromPipelineByPropertyName = $True
        )]
        [string]$Timezone,
            
        [Parameter(
            ParameterSetName = 'Manual', 
            ValueFromPipelineByPropertyName = $True
        )]
        [string]$Language,
            
        [Parameter(
            ParameterSetName = 'Manual', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('Department')]
        [string]$Dept,

        [Parameter(
            ParameterSetName = 'Manual', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('host_key')]
        [string]$HostKey,
            
        [Parameter(
            ParameterSetName = 'Manual', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('vanity_name')]
        [string]$VanityName,

        [Parameter(
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('group_id', 'group', 'id', 'groupids', 'groups')]
        [string[]]$GroupId,

        [Parameter(
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [string[]]$SchedulingAssistant = 'admin@company.com',
            
        [Parameter(ParameterSetName = 'AdAccount')]
        [Parameter(ParameterSetName = 'Manual')]
        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,
            
        [Parameter(ParameterSetName = 'AdAccount')]
        [Parameter(ParameterSetName = 'Manual')]
        [ValidateNotNullOrEmpty()]
        [string]$ApiSecret
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'AdAccount') {

            #Get AD user with the properties that the script uses
            $user = (get-aduser -identity $AdAccount -Properties EmailAddress, Surname, GivenName, OfficePhone, Department, Office, EmployeeId)
            
            $params = @{
                'UsePmi' = $True
            }

            if ($User.EmailAddress) {
                $Email = $User.EmailAddress
                $params.Add('EmailAddress', $Email)
            }

            if ($User.Surname) {
                $params.Add('LastName', $User.Surname)
            }

            if ($User.GivenName) {
                $params.Add('FirstName', $User.GivenName)
            }

            if ($User.Department) {
                $params.Add('Dept', $User.Department)
            }

            if ($User.OfficePhone) {
                $Pmi = $User.OfficePhone.substring($User.OfficePhone.Length - 10, $User.OfficePhone.Length - 2)
                $params.Add('Pmi', $Pmi)
            }

            if ($HostKey) {
                $params.Add('HostKey', "$HostKey") #Creates a 
            }
                
            if ($User.Office) {
                $OfficeLocation = switch ($User.Office) {
                    'OfficeeName1' { 'Office 1' }
                    'OfficeeName2' { 'Office 2' }
                    'OfficeeName3' { 'Office 3' }
                }

                $GroupID = ((Get-ZoomGroups) | where-object {$_ -match "$OfficeLocation"}).id

                $params.Add('GroupId', $GroupId)
            }

            if ($ApiKey) {
                $params.Add('ApiKey', $ApiKey)
            }

            if ($ApiKey) {
                $params.Add('ApiSecret', $ApiSecret)
            }
            
            New-CompanyZoomUser @params
        } elseif ($PSCmdlet.ParameterSetName -eq 'Manual') {
            $creds = @{
                ApiKey     = 'ApiKey'
                ApiSecret  = 'ApiSecret'
            }

            #Create new user
            $defaultNewUserParams = @{
                Action    = $Action
                Type      = $Type
                Email     = $Email
            }

            function Remove-NonPsBoundParameters {
                param (
                    $Obj,
                    $Parameters = $PSBoundParameters
                )
          
                process {
                    $NewObj = @{ }
              
                    foreach ($Key in $Obj.Keys) {
                        if ($Parameters.ContainsKey($Obj.$Key) -or -not [string]::IsNullOrWhiteSpace($Obj.Key)) {
                            $Newobj.Add($Key, (get-variable $Obj.$Key).value)
                        }
                    }
              
                    return $NewObj
                }
            }

            $newUserParams = @{
                FirstName = 'FirstName'
                LastName  = 'LastName'
            }

            $newUserParams = Remove-NonPsBoundParameters($newUserParams)

            New-ZoomUser @defaultNewUserParams @newUserParams @creds

            #Update parameters that cant be entered with new user
            $updateParams = @{
                UserId                                   = 'Email'
                HostKey                                  = 'HostKey'
                Pmi                                      = 'Pmi'
                Timezone                                 = 'Timezone'
                Language                                 = 'Language'
                Dept                                     = 'Department'
                VanityName                               = 'VanityName'
                UsePmi                                   =  'UsePmi'
                RequirePasswordForSchedulingNewMeetings  = 'RequirePasswordForSchedulingNewMeetings' 
                RequirePasswordForPmiMeetings            = 'RequirePasswordForPmiMeetings' 
                EmbedPasswordInJoinLink                  = 'EmbedPasswordInJoinLink' 
            }

            $updateParams = Remove-NonPsBoundParameters($updateParams)

            $passwordSettings = @{
                = $True
                = 'all'
                = $True
            }

            Update-ZoomUser @updateParams @passwordSettings @creds

            #Add user to group
            if ($GroupId) {
                Add-ZoomGroupMember -groupid $GroupId -MemberEmail $email @creds
            }

            #Add scheduling permission on behalf of Admin
            if ($SchedulingAssistant) {
                Add-ZoomUserAssistants -UserId $Email -AssistantEmail $SchedulingAssistant @creds
            }
        }
    }
}
