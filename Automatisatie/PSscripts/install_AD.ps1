$DomainName = "PAMCorp.be"
$Password = "Password1234!"
$SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force

Install-WindowsFeature AD-domain-services -IncludeManagementTools -Confirm:$false
Install-ADDSForest -DomainName PAMCorp.be -InstallDNS -SafeModeAdministratorPassword $SecurePassword -Confirm:$false