<#

.SYNOPSIS
Upload a user’s profile picture.
.DESCRIPTION
Upload a user’s profile picture.
.PARAMETER UserId
The user ID or email address.
.PARAMETER FileName
The path to the file to be uploaded.
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
.EXAMPLE
Update-ZoomProfilePicture -UserId 'jmcevoy@lawfirm.com' -FileName "C:\Development\Zoom\PowerShell-Zoom-Wrapper-master\mcevoy.jpg"
.OUTPUTS
A hastable with the Zoom API response.

#>

$Parent = Split-Path $PSScriptRoot -Parent
import-module "$Parent\ZoomModule.psm1"

function Update-ZoomProfilePicture {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('Email', 'EmailAddress', "Id")]
        [string]$UserId,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 1
        )]
        [ValidateScript({Test-Path $_})]
        [string]$FileName,

        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,

        [ValidateNotNullOrEmpty()]
        [string]$ApiSecret
    )

    begin {
        #Get Zoom Api Credentials
        if (-not $ApiKey -or -not $ApiSecret) {
            $ApiCredentials = Get-ZoomApiCredentials
            $ApiKey = $ApiCredentials.ApiKey
            $ApiSecret = $ApiCredentials.ApiSecret
        }

        #Generate Header with JWT (JSON Web Token)
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/users/$UserId/picture"
        $LF = "`r`n";
        $FileBytes = Get-Content -Path $FileName -Encoding Byte
        $FileContent = [System.Text.Encoding]::GetEncoding('iso-8859-1').GetString($FileBytes);
        $Boundary = [System.Guid]::NewGuid().ToString()


        $RequestBody = ( 
            "--$Boundary",
            "Content-Disposition: form-data; name=`"pic_file`"; filename=`"$FileName`"",
            "Content-Type: image/jpeg$LF",
            "$FileContent",
            "--$Boundary--"
        ) -join $LF

        
        try {
            Invoke-RestMethod -Uri $Request.Uri -ContentType "multipart/form-data; boundary=`"$Boundary`"" -Headers $headers -Body $RequestBody -Method POST
        } catch {
            Write-Error -Message "$($_.exception.message)" -ErrorId $_.exception.code -Category InvalidOperation
        }
    }
}