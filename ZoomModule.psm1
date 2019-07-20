<#

.DESCRIPTION
A collection of helper functions that support the primary functions.

#>

function Get-ZoomApiCredentials {
    <#
    .SYNOPSIS
    Gets a hashtable for a Zoom Api REST body that includes the api key and secret.
    .EXAMPLE
    $ZoomApiCredentials = Get-ZoomApiAuth
    .OUTPUTS
    Hashtable
    .LINK
    https://marketplace.zoom.us/docs/guides/authorization/jwt/jwt-with-zoom
    .LINK
    https://github.com/nickrod518/PowerShell-Scripts/tree/master/Zoom
    #>
    [CmdletBinding()]
    Param()

    try {
        Write-Verbose -Message 'Retrieving Zoom API Credentials.'
        if (-not $Global:ZoomApiKey) {
            $Global:ZoomApiKey = if ($PSPrivateMetadata.JobId) {
                Get-AutomationVariable -Name ZoomApiKey
            }
            else {
                Read-Host 'Enter Zoom Api key (push ctrl + c to exit)'
            }
        }

        if (-not $Global:ZoomApiSecret) {
            $Global:ZoomApiSecret = if ($PSPrivateMetadata.JobId) {
                Get-AutomationVariable -Name ZoomApiSecret
            }
            else {
                Read-Host 'Enter Zoom Api secret (push ctrl + c to exit)'
            }
        }

        @{
            'ApiKey'    = $Global:ZoomApiKey
            'ApiSecret' = $Global:ZoomApiSecret
        }
        Write-Verbose 'Retrieved API Credentials.'
    }
    catch {
        Write-Error "Problem getting Zoom Api Authorization variables:`n$_"
    }
}

function Get-ZoomTimeZones {
    <#
.DESCRIPTION
Returns Zoom timezone codes.
.EXAMPLE
(Get-ZoomTimeZones).Contains('Pacific/Midway')
.LINK
https://github.com/nickrod518/PowerShell-Scripts/blob/master/Zoom/Zoom.psm1
.LINK
https://marketplace.zoom.us/docs/api-reference/other-references/abbreviation-lists#timezones
#>
    
    @{
        'Pacific/Midway'                 = '"Midway Island, Samoa"'
        'Pacific/Pago_Pago'              = 'Pago Pago'
        'Pacific/Honolulu'               = 'Hawaii'
        'America/Anchorage'              = 'Alaska'
        'America/Vancouver'              = 'Vancouver'
        'America/Los_Angeles'            = 'Pacific Time (US and Canada)'
        'America/Tijuana'                = 'Tijuana'
        'America/Edmonton'               = 'Edmonton'
        'America/Denver'                 = 'Mountain Time (US and Canada)'
        'America/Phoenix'                = 'Arizona'
        'America/Mazatlan'               = 'Mazatlan'
        'America/Winnipeg'               = 'Winnipeg'
        'America/Regina'                 = 'Saskatchewan'
        'America/Chicago'                = 'Central Time (US and Canada)'
        'America/Mexico_City'            = 'Mexico City'
        'America/Guatemala'              = 'Guatemala'
        'America/El_Salvador'            = 'El Salvador'
        'America/Managua'                = 'Managua'
        'America/Costa_Rica'             = 'Costa Rica'
        'America/Montreal'               = 'Montreal'
        'America/New_York'               = 'Eastern Time (US and Canada)'
        'America/Indianapolis'           = 'Indiana (East)'
        'America/Panama'                 = 'Panama'
        'America/Bogota'                 = 'Bogota'
        'America/Lima'                   = 'Lima'
        'America/Halifax'                = 'Halifax'
        'America/Puerto_Rico'            = 'Puerto Rico'
        'America/Caracas'                = 'Caracas'
        'America/Santiago'               = 'Santiago'
        'America/St_Johns'               = 'Newfoundland and Labrador'
        'America/Montevideo'             = 'Montevideo'
        'America/Araguaina'              = 'Brasilia'
        'America/Argentina/Buenos_Aires' = '"Buenos Aires, Georgetown"'
        'America/Godthab'                = 'Greenland'
        'America/Sao_Paulo'              = 'Sao Paulo'
        'Atlantic/Azores'                = 'Azores'
        'Canada/Atlantic'                = 'Atlantic Time (Canada)'
        'Atlantic/Cape_Verde'            = 'Cape Verde Islands'
        'UTC'                            = 'Universal Time UTC'
        'Etc/Greenwich'                  = 'Greenwich Mean Time'
        'Europe/Belgrade'                = '"Belgrade, Bratislava, Ljubljana"'
        'CET'                            = '"Sarajevo, Skopje, Zagreb"'
        'Atlantic/Reykjavik'             = 'Reykjavik'
        'Europe/Dublin'                  = 'Dublin'
        'Europe/London'                  = 'London'
        'Europe/Lisbon'                  = 'Lisbon'
        'Africa/Casablanca'              = 'Casablanca'
        'Africa/Nouakchott'              = 'Nouakchott'
        'Europe/Oslo'                    = 'Oslo'
        'Europe/Copenhagen'              = 'Copenhagen'
        'Europe/Brussels'                = 'Brussels'
        'Europe/Berlin'                  = '"Amsterdam, Berlin, Rome, Stockholm, Vienna"'
        'Europe/Helsinki'                = 'Helsinki'
        'Europe/Amsterdam'               = 'Amsterdam'
        'Europe/Rome'                    = 'Rome'
        'Europe/Stockholm'               = 'Stockholm'
        'Europe/Vienna'                  = 'Vienna'
        'Europe/Luxembourg'              = 'Luxembourg'
        'Europe/Paris'                   = 'Paris'
        'Europe/Zurich'                  = 'Zurich'
        'Europe/Madrid'                  = 'Madrid'
        'Africa/Bangui'                  = 'West Central Africa'
        'Africa/Algiers'                 = 'Algiers'
        'Africa/Tunis'                   = 'Tunis'
        'Africa/Harare'                  = '"Harare, Pretoria"'
        'Africa/Nairobi'                 = 'Nairobi'
        'Europe/Warsaw'                  = 'Warsaw'
        'Europe/Prague'                  = 'Prague Bratislava'
        'Europe/Budapest'                = 'Budapest'
        'Europe/Sofia'                   = 'Sofia'
        'Europe/Istanbul'                = 'Istanbul'
        'Europe/Athens'                  = 'Athens'
        'Europe/Bucharest'               = 'Bucharest'
        'Asia/Nicosia'                   = 'Nicosia'
        'Asia/Beirut'                    = 'Beirut'
        'Asia/Damascus'                  = 'Damascus'
        'Asia/Jerusalem'                 = 'Jerusalem'
        'Asia/Amman'                     = 'Amman'
        'Africa/Tripoli'                 = 'Tripoli'
        'Africa/Cairo'                   = 'Cairo'
        'Africa/Johannesburg'            = 'Johannesburg'
        'Europe/Moscow'                  = 'Moscow'
        'Asia/Baghdad'                   = 'Baghdad'
        'Asia/Kuwait'                    = 'Kuwait'
        'Asia/Riyadh'                    = 'Riyadh'
        'Asia/Bahrain'                   = 'Bahrain'
        'Asia/Qatar'                     = 'Qatar'
        'Asia/Aden'                      = 'Aden'
        'Asia/Tehran'                    = 'Tehran'
        'Africa/Khartoum'                = 'Khartoum'
        'Africa/Djibouti'                = 'Djibouti'
        'Africa/Mogadishu'               = 'Mogadishu'
        'Asia/Dubai'                     = 'Dubai'
        'Asia/Muscat'                    = 'Muscat'
        'Asia/Baku'                      = '"Baku, Tbilisi, Yerevan"'
        'Asia/Kabul'                     = 'Kabul'
        'Asia/Yekaterinburg'             = 'Yekaterinburg'
        'Asia/Tashkent'                  = '"Islamabad, Karachi, Tashkent"'
        'Asia/Calcutta'                  = 'India'
        'Asia/Kathmandu'                 = 'Kathmandu'
        'Asia/Novosibirsk'               = 'Novosibirsk'
        'Asia/Almaty'                    = 'Almaty'
        'Asia/Dacca'                     = 'Dacca'
        'Asia/Krasnoyarsk'               = 'Krasnoyarsk'
        'Asia/Dhaka'                     = '"Astana, Dhaka"'
        'Asia/Bangkok'                   = 'Bangkok'
        'Asia/Saigon'                    = 'Vietnam'
        'Asia/Jakarta'                   = 'Jakarta'
        'Asia/Irkutsk'                   = '"Irkutsk, Ulaanbaatar"'
        'Asia/Shanghai'                  = '"Beijing, Shanghai"'
        'Asia/Hong_Kong'                 = 'Hong Kong'
        'Asia/Taipei'                    = 'Taipei'
        'Asia/Kuala_Lumpur'              = 'Kuala Lumpur'
        'Asia/Singapore'                 = 'Singapore'
        'Australia/Perth'                = 'Perth'
        'Asia/Yakutsk'                   = 'Yakutsk'
        'Asia/Seoul'                     = 'Seoul'
        'Asia/Tokyo'                     = '"Osaka, Sapporo, Tokyo"'
        'Australia/Darwin'               = 'Darwin'
        'Australia/Adelaide'             = 'Adelaide'
        'Asia/Vladivostok'               = 'Vladivostok'
        'Pacific/Port_Moresby'           = '"Guam, Port Moresby"'
        'Australia/Brisbane'             = 'Brisbane'
        'Australia/Sydney'               = '"Canberra, Melbourne, Sydney"'
        'Australia/Hobart'               = 'Hobart'
        'Asia/Magadan'                   = 'Magadan'
        'SST'                            = 'Solomon Islands'
        'Pacific/Noumea'                 = 'New Caledonia'
        'Asia/Kamchatka'                 = 'Kamchatka'
        'Pacific/Fiji'                   = '"Fiji Islands, Marshall Islands"'
        'Pacific/Auckland'               = '"Auckland, Wellington"'
        'Asia/Kolkata'                   = '"Mumbai, Kolkata, New Delhi"'
        'Europe/Kiev'                    = 'Kiev'
        'America/Tegucigalpa'            = 'Tegucigalpa'
        'Pacific/Apia'                   = 'Independent State of Samoa'
    }
}

function New-JWT {
    <#
    .DESCRIPTION
    Encodes a JWT header, payload and signature.
    .EXAMPLE
    New-JWT -Algorithm 'HS256' -type 'JWT' -Issuer $api_key -SecretKey $api_secret -ValidforSeconds 30
    .EXAMPLE
    $Token = New-JWT -Algorithm 'HS256' -type 'JWT' -Issuer $api_key -SecretKey $api_secret -ValidforSeconds 30
    #>
    param (
        [Parameter(Mandatory = $True)]
        [ValidateSet('HS256', 'HS384', 'HS512')]
        [string]$Algorithm,
    
        $Type = $null,
    
        [Parameter(Mandatory = $True)]
        [string]$Issuer,
    
        [int]$ValidforSeconds = $null,
    
        [Parameter(Mandatory = $True)]
        [string]$SecretKey
    )

    Write-Verbose 'Generating JWT'
    $Exp = [int][double]::parse((Get-Date -Date $((Get-Date).addseconds($ValidforSeconds).ToUniversalTime()) -UFormat %s)) # Grab Unix Epoch Timestamp and add desired expiration
    
    $Header = @{ 
        alg = $Algorithm
        typ = $Type 
    }
    
    $Payload = @{ 
        iss = $Issuer
        exp = $Exp
    }
    
    $Headerjson = $Header | ConvertTo-Json -Compress
    $Payloadjson = $Payload | ConvertTo-Json -Compress
    
    $Headerjsonbase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Headerjson)).Split('=')[0].Replace('+', '-').Replace('/', '_')
    $Payloadjsonbase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Payloadjson)).Split('=')[0].Replace('+', '-').Replace('/', '_')
    
    $ToBeSigned = $Headerjsonbase64 + "." + $Payloadjsonbase64
    
    $SigningAlgorithm = switch ($Algorithm) {
        "HS256" { New-Object System.Security.Cryptography.HMACSHA256 }
        "HS384" { New-Object System.Security.Cryptography.HMACSHA384 }
        "HS512" { New-Object System.Security.Cryptography.HMACSHA512 }
    } 
    
    $SigningAlgorithm.Key = [System.Text.Encoding]::UTF8.GetBytes($SecretKey)
    $Signature = [Convert]::ToBase64String($SigningAlgorithm.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($ToBeSigned))).Split('=')[0].Replace('+', '-').Replace('/', '_')
    
    $Token = "$Headerjsonbase64.$Payloadjsonbase64.$Signature"
    
    Write-Output $Token
}

function New-ZoomHeaders {
    param (
        [string]$ApiKey,
        [string]$ApiSecret
    )
    Write-Verbose 'Generating JWT'
    $Token = New-JWT -Algorithm 'HS256' -type 'JWT' -Issuer $ApiKey -SecretKey $ApiSecret -ValidforSeconds 30

    Write-Verbose 'Generating Headers'
    $Headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $Headers.Add('Content-Type' , 'application/json')
    $Headers.Add('Authorization', 'Bearer ' + $Token)

    Write-Output $Headers
}

Export-ModuleMember -function *
