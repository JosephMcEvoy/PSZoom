function ConvertTo-LoginTypeCode {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        [string]$Code
    )

    process {
        $Code = switch ($Code) {
            'Facebook'         {'0'}
            'FacebookOAuth'    {'0'}
            'Google'           {'1'}
            'GoogleAuth'       {'1'}
            'Apple'            {'24'}
            'AppleOAuth'       {'24'}
            'Microsoft'        {'27'}
            'MicrosoftOauth'   {'27'}
            'MobileDevice'     {'97'}
            'RingCentral'      {'98'}
            'RingCentralOAuth' {'98'}
            'APIuser'          {'99'}
            'ZoomWorkemail'    {'100'}
            'SSO'              {'101'}
            'PhoneNumber'      {'11'}
            'WeChat'           {'21'}
            'Alipay'           {'23'}
            Default { $Code }
        }

        Write-Output $Code
    }
}