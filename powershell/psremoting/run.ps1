$ErrorActionPreference = 'Stop'
Function New-WinRmComputerCertificate() {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)][string]$Fqdn
    )
    $ErrorActionPreference = 'Stop'
    if(!$Fqdn) {
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
Function Disable-WinRmUac() {
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name LocalAccountTokenFilterPolicy -Value 1
}
[void](Enable-PSRemoting -SkipNetworkProfileCheck -Force)
$Certificate = New-WinRmComputerCertificate
[void](New-Item -Path WSMan:\LocalHost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $Certificate.Thumbprint -Force)
[void](New-NetFirewallRule -DisplayName 'WinRM HTTPS-In' -Name 'WinRM HTTPS-In' -Profile Any -LocalPort 5986 -Protocol TCP)
Disable-WinRmUac
