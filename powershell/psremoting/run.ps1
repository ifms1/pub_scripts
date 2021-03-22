Function New-WinRmComputerCertificate() {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)][string]$Fqdn
    )
    $ErrorActionPreference = 'Stop'
    if(null -eq $PSBoundParameters.Values('Fqdn')) {
        $Fqdn = $Env:COMPUTERNAME
    }
    try {
        $result = New-SelfSignedCertificate -CertstoreLocation Cert:\LocalMachine\My -DnsName $Fqdn -FriendlyName "WinRm Certificate"
    }
    catch {
        return $_
    }
    return $result
}
try {
    Enable-PSRemoting -SkipNetworkProfileCheck -Force
    $Certificate = New-WinRmComputerCertificate
    New-Item -Path WSMan:\LocalHost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $Certificate.Thumbprint -Force
    New-NetFirewallRule -DisplayName 'WinRM HTTPS-In' -Name 'WinRM HTTPS-In' -Profile Any -LocalPort 5986 -Protocol TCP
}
catch {
    return $_
}
