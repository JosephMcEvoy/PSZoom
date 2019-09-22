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
.OUTPUTS
A hastable with the Zoom API response.
.EXAMPLE
Update-ZoomProfilePicture -UserId 'jmcevoy@lawfirm.com' -FileName "C:\Development\Zoom\PSZoom\mcevoy.jpg"
.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/users/userpicture

#>

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
        [string[]]$UserId,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 1
        )]
        [ValidateScript({Test-Path -Path $_})]
        [string]$FileName,

        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,

        [ValidateNotNullOrEmpty()]
        [string]$ApiSecret
    )

    begin {
        #Generate Header with JWT (JSON Web Token) using the Api Key/Secret
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        foreach ($user in $UserId) {
            $Request = [System.UriBuilder]"https://api.zoom.us/v2/users/$user/picture"
            $LF = "`r`n";

            if ($PSVersionTable.PSVersion.Major -lt 6) {
                $FileBytes = Get-Content -Path $FileName -Encoding Byte
            } else {
                $FileBytes = Get-Content -Path $FileName -AsByteStream
            }
            
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
                $response = Invoke-RestMethod -Uri $request.Uri -ContentType "multipart/form-data; boundary=`"$Boundary`"" -Headers $headers -Body $RequestBody -Method POST
            } catch {
                Write-Error -Message "$($_.Exception.Message)" -ErrorId $_.Exception.Code -Category InvalidOperation
            }
    
            Write-Output $response
        }
    }
}