function Select-DuoAccount {
    <#
    .SYNOPSIS
    Select Duo Account to use for Admin API

    .DESCRIPTION
    Takes values from the account list and creates API credentials for sub account

    .PARAMETER AccountId
    Duo Account Id

    .PARAMETER Name
    Duo Account name

    .PARAMETER Clear
    Clear credentials

    .PARAMETER Quiet
    Suppress output

    .EXAMPLE
    Select-DuoAccount -Name 'Some Company Name'

    .EXAMPLE
    Select-DuoAccount -AccountId SOMEACCOUNTID
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, ParameterSetName = 'AccountId')]
        [string]$AccountId,

        [Parameter(Mandatory = $true, ParameterSetName = 'AccountName')]
        [string]$Name,

        [Parameter(ParameterSetName = 'Clear')]
        [switch]$Clear,

        [Parameter()]
        [switch]$Quiet
    )

    if ($Clear) {
        $script:DuoApiHost = $script:DuoAccountsApiHost
        $script:DuoAccountId = $null
    }

    if (!$script:DuoAccountsList) {
        Get-DuoAccounts | Out-Null
    }

    if ($Name) {
        $Account = $script:DuoAccountsList | Where-Object { $_.name -eq $Name }
        if (@($Account).Count -gt 1) {
            Write-Error 'More then one account found, use AccountId.' -ErrorAction Stop
        }
    }

    if ($AccountId) {
        $Account = $script:DuoAccountsList | Where-Object { $_.account_id -eq $AccountId }
    }

    if ($Account) {
        $script:DuoApiHost = $Account.api_hostname
        $script:DuoIntegrationKey = $script:DuoAccountsIntegrationKey
        $script:DuoSecretKey = $script:DuoAccountsSecretKey
        $script:DuoAccountId = $Account.account_id
        if (!$Quiet) {
            Write-Information "Account: $($Account.name) ($($Account.account_id))"
        }
    } else {
        Write-Error 'Invalid Account specified'
    }
}
