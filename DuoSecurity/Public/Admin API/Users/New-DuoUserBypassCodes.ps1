function New-DuoUserBypassCodes {
    <#
    .SYNOPSIS
    Create Bypass Codes for User
    
    .DESCRIPTION
    Clear all existing bypass codes for the user with ID user_id and return a list of count newly generated bypass codes, or specify codes that expire after valid_secs seconds, or reuse_count uses. Requires "Grant write resource" API permission.

Object limits: 100 bypass codes per user.
    
    .PARAMETER UserId
    The ID of the User
    
    .PARAMETER Count
    Number of new bypass codes to create. At most 10 codes (the default) can be created at a time. Codes will be generated randomly.
    
    .PARAMETER Codes
    CSV string of codes to use. Mutually exclusive with count.
    
    .PARAMETER ReuseCount
    The number of times generated bypass codes can be used. If 0, the codes will have an infinite reuse_count. Default: 1
    
    .PARAMETER ValidSecs
    The number of seconds for which generated bypass codes remain valid. If 0 (the default) the codes will never expire.
    
    .EXAMPLE
    New-DuoUserBypassCodes -UserId SOMEUSERID -Count 1 -ValidSecs 30

    #>
    [CmdletBinding(DefaultParameterSetName = 'Count')]
    Param(
        [Parameter(ValueFromPipelineByPropertyName = $true, Mandatory = $true)]
        [Alias('user_id')]
        [string]$UserId,
        
        [Parameter(ParameterSetName = 'Count')]
        [ValidateRange(1, 10)]
        [int]$Count = 10,

        [Parameter(ParameterSetName = 'Codes')]
        [string[]]$Codes = @(),

        [Parameter()]
        [int]$ReuseCount = 1,

        [Parameter()]
        [int]$ValidSecs = 0
    )

    process { 
        $Params = @{
            reuse_count = $ReuseCount
            valid_secs  = $ValidSecs
        }

        if ($Codes) {
            $Params.codes = $Codes -join ','
        }
        else {
            $Params.count = $Count
        }

        $DuoRequest = @{
            Method = 'POST'
            Path   = '/admin/v1/users/{0}/bypass_codes' -f $UserId
            Params = $Params
        }

        $Request = Invoke-DuoRequest @DuoRequest
        if ($Request.stat -ne 'OK') {
            $Request
        }
        else {
            $Request.response
        }
    }
}