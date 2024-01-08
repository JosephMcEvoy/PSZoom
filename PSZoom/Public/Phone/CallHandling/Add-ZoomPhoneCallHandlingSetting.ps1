<#

.SYNOPSIS
Add a call handling settings for a specific Setting Type.

.DESCRIPTION
Add a call handling settings for a specific Setting Type.

.PARAMETER ExtensionId
Unique Identifier of the Extension.

.PARAMETER SettingType
The specific type of calling handling settings
Allowed: business_hours ┃ closed_hours ┃ holiday_hours

.PARAMETER SubSettingType
The specific sub-type of calling handling settings
Allowed: call_forwarding ┃ holiday

.PARAMETER Description
The external phone number's description. This is only required for the call_forwarding sub-setting.

.PARAMETER Holidayid
The holiday's ID. This is only required for the call_forwarding sub-setting.

.PARAMETER PhoneNumber
The external phone number, in E.164 format. This is only required for the call_forwarding sub-setting.

.PARAMETER Name
The name of the holiday. This is only required for the holiday sub-setting.

.PARAMETER From
The holiday's start date and time, in yyyy-MM-dd'T'HH:mm:ss'Z' format. This is only required for the holiday sub-setting.

.PARAMETER To
The holiday's end date and time, in yyyy-MM-dd'T'HH:mm:ss'Z' format. This is only required for the holiday sub-setting.

.OUTPUTS
An array of Objects

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/addCallHandling

.EXAMPLE
List the Holiday Hours Call Handling settings for a extension.
ADD-ZoomPhoneCallHandlingSetting -ExtensionId "tuycigvohbojnkpml4" -SettingType "holiday_hours" -SubSettingType "holiday" -Name -From -To

.EXAMPLE
List the Holiday Hours Call Handling settings for a extension.
ADD-ZoomPhoneCallHandlingSetting -ExtensionId "tuycigvohbojnkpml4" -SettingType "holiday_hours" -SubSettingType "call_forwarding" -Description -Holidayid -PhoneNumber

#>

function Add-ZoomPhoneCallHandlingSetting {    
    [CmdletBinding(SupportsShouldProcess = $True)]
    
    Param(


        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('extension_id')]
        [string[]]$ExtensionId,


        [Parameter(
            Mandatory = $True, 
            Position = 1
        )]
        [ValidateSet('business_hours','closed_hours','holiday_hours')]
        [string]$SettingType,


        [Parameter(
            Mandatory = $True, 
            Position = 2
        )]
        [ValidateSet('call_forwarding','holiday')]
        [string]$SubSettingType
    )

    DynamicParam {
        if ($SubSettingType -eq "call_forwarding") {
        
            #create ParameterAttribute Objects for business_hours
            $Description = New-Object System.Management.Automation.ParameterAttribute
            $Description.Mandatory = $true
            $Description.Position = 3
            $Holidayid = New-Object System.Management.Automation.ParameterAttribute
            $Holidayid.Mandatory = $true
            $Holidayid.Position = 4
            $PhoneNumber = New-Object System.Management.Automation.ParameterAttribute
            $PhoneNumber.Mandatory = $true
            $PhoneNumber.Position = 5

            #create an attributecollection object for the attributes we just created.
            $DescriptionAttributeCollection = new-object -Type System.Collections.ObjectModel.Collection[System.Attribute]
            $HolidayIdAttributeCollection = new-object -Type System.Collections.ObjectModel.Collection[System.Attribute]
            $PhoneNumberAttributeCollection = new-object -Type System.Collections.ObjectModel.Collection[System.Attribute]

            #add our custom attributes
            $DescriptionAttributeCollection.Add($Description)
            $HolidayIdAttributeCollection.Add($Holidayid)
            $PhoneNumberAttributeCollection.Add($PhoneNumber)
            
            #add our paramater specifying the attribute collection
            $DescriptionParam = New-Object -Type System.Management.Automation.RuntimeDefinedParameter('Description', [string], $DescriptionAttributeCollection)
            $HolidayidParam = New-Object -Type System.Management.Automation.RuntimeDefinedParameter('Holidayid', [string], $HolidayIdAttributeCollection)
            $PhoneNumberParam = New-Object -Type System.Management.Automation.RuntimeDefinedParameter('PhoneNumber', [string], $PhoneNumberAttributeCollection)

            #expose the name of our parameter
            $paramDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            $paramDictionary.Add('Description', $DescriptionParam)
            $paramDictionary.Add('Holidayid', $HolidayidParam)
            $paramDictionary.Add('PhoneNumber', $PhoneNumberParam)
            return $paramDictionary

        }elseif ($SubSettingType -eq "holiday") {
        
            #create ParameterAttribute Objects for closed_hours
            $Name = New-Object System.Management.Automation.ParameterAttribute
            $Name.Mandatory = $true
            $Name.Position = 3
            $To = New-Object System.Management.Automation.ParameterAttribute
            $To.Mandatory = $true
            $To.Position = 4
            $From = New-Object System.Management.Automation.ParameterAttribute
            $From.Mandatory = $true
            $From.Position = 5

            #create an attributecollection object for the attributes we just created.
            $NameAttributeCollection = new-object -Type System.Collections.ObjectModel.Collection[System.Attribute]
            $ToAttributeCollection = new-object -Type System.Collections.ObjectModel.Collection[System.Attribute]
            $FromAttributeCollection = new-object -Type System.Collections.ObjectModel.Collection[System.Attribute]

            #add our custom attributes
            $NameAttributeCollection.Add($Name)
            $ToAttributeCollection.Add($To)
            $FromAttributeCollection.Add($From)
            
            #add our paramater specifying the attribute collection
            $NameParam = New-Object -Type System.Management.Automation.RuntimeDefinedParameter('Name', [string], $NameAttributeCollection)
            $ToParam = New-Object -Type System.Management.Automation.RuntimeDefinedParameter('To', [string], $ToAttributeCollection)
            $FromParam = New-Object -Type System.Management.Automation.RuntimeDefinedParameter('From', [string], $FromAttributeCollection)

            #expose the name of our parameter
            $paramDictionary = New-Object -Type System.Management.Automation.RuntimeDefinedParameterDictionary
            $paramDictionary.Add('Name', $NameParam)
            $paramDictionary.Add('To', $ToParam)
            $paramDictionary.Add('From', $FromParam)
            return $paramDictionary
            
        }
    }

    begin {

        switch ($SubSettingType) {
            "call_forwarding"{

                # Test to verify time is in correct format
                if (!($PSBoundParameters['PhoneNumber'] -match "^\+[1-9]\d{1,14}$")){

                    Throw "Incorrect `"-PhoneNumber`" format. Please verify number is in E.164 format."
                }

                # Setting variables
                $CallForwardingDescription = $PSBoundParameters['Description']
                $CallForwardingHolidayId = $PSBoundParameters['HolidayId']
                $CallForwardingPhoneNumber = $PSBoundParameters['PhoneNumber']
            }
            "holiday"{

                # Test to verify time is in correct format
                if (!($PSBoundParameters['To'] -match "\d{4}-(?:0[1-9]|1[0-2])-(?:0[1-9]|[1-2]\d|3[0-1])T(?:[0-1]\d|2[0-3]):[0-5]\d:[0-5]\dZ")){

                    Throw "Incorrect `"-To`" time format. Please verify time is in format `"yyyy-MM-dd'T'HH:mm:ss'Z'`"."
                }

                if (!($PSBoundParameters['From'] -match "\d{4}-(?:0[1-9]|1[0-2])-(?:0[1-9]|[1-2]\d|3[0-1])T(?:[0-1]\d|2[0-3]):[0-5]\d:[0-5]\dZ")){

                    Throw "Incorrect `"-From`" time format. Please verify time is in format `"yyyy-MM-dd'T'HH:mm:ss'Z'`"."
                }

                # Setting variables
                $HolidayName = $PSBoundParameters['Name']
                $HolidayTo = $PSBoundParameters['To']
                $HolidayFrom = $PSBoundParameters['From']
            }
        }
    }
    
    process {
        
        foreach ($Extension in $ExtensionId) {

            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/extension/$Extension/call_handling/settings/$SettingType"


            switch ($SubSettingType) {
                "call_forwarding"{

                    #region settings
                    $settings = @{ }

                    if ($PSBoundParameters.ContainsKey('Description')) {
                        $settings.Add("description", $CallForwardingDescription)
                    }
    
                    if ($PSBoundParameters.ContainsKey('HolidayId')) {
                        $settings.Add("holiday_id", $CallForwardingHolidayId)
                    }
    
                    if ($PSBoundParameters.ContainsKey('PhoneNumber')) {
                        $settings.Add("phone_number", $CallForwardingPhoneNumber)
                    }
                    #endregion settings

                }
                "holiday"{

                    #region settings
                    $settings = @{ }

                    if ($PSBoundParameters.ContainsKey('Name')) {
                        $settings.Add("name", $HolidayName)
                    }
    
                    if ($PSBoundParameters.ContainsKey('To')) {
                        $settings.Add("to", $HolidayTo)
                    }
    
                    if ($PSBoundParameters.ContainsKey('From')) {
                        $settings.Add("from", $HolidayFrom)
                    }
                    #endregion settings
                }
            }
            

            #region body
            $RequestBody = @{ }

            $KeyValuePairs = @{
                'settings'              = $settings
                'sub_setting_type'      = $SubSettingType
            }

            $KeyValuePairs.Keys | ForEach-Object {
                if (-not ([string]::IsNullOrEmpty($KeyValuePairs.$_))) {
                    $RequestBody.Add($_, $KeyValuePairs.$_)
                }
            }
            #endregion body

            $RequestBody = $RequestBody | ConvertTo-Json
            $Message = 
@"

Method: POST
URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
Body:
$RequestBody
"@

            if ($pscmdlet.ShouldProcess($Message, $Extension, "Update call handling")) {
                $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $requestBody -Method POST
        
                if (-not $PassThru) {
                    Write-Output $response
                }
            }
        }

        if ($PassThru) {
            Write-Output $UserId
        }
    }
}









