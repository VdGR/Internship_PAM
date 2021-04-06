Import-Module ActiveDirectory

$filePath = Read-Host -Prompt "Please enter the path to your CSV file: "

$parentOU = "PAMCorp"
$domaincontroller = "DC=$parentOU,DC=be"

New-ADOrganizationalUnit -Name $parentOU -Path $domaincontroller

$organizationalUnitsInParentUnit = "Users", "Computers"

foreach($organizationalUnit in $organizationalUnitsInParentUnit)
{
    New-ADOrganizationalUnit $organizationalUnit -Path "OU=$parentOU,$domaincontroller"
}

$differenceUnitsInCompany = "Security", "Network", "Accounting", "Systems"

foreach($organizationalUnitInCompany in $differenceUnitsInCompany)
{
    New-ADOrganizationalUnit $organizationalUnitInCompany -Path "OU=Users,OU=$parentOU,$domaincontroller"
}

$people = Import-Csv $filePath
$count = 0

foreach($person in $people)
{
    $firstName = $person.voornaam -replace '(^\s+|\s+$)','' -replace '\s+',' ' -replace '\/+','-'
    $name = $person.naam -replace '(^\s+|\s+$)','' -replace '\s+',' ' -replace '\/+','-'
    $function = $person.functie
    $unit = $person.afdeling
    $fullName = "$firstName $name"

    if($fullName.Length -gt 20)
    {
        $fullName = $fullName.Substring(0,20)
    }

    $organizationalUnitPathPeople = "OU=$unit,OU=Users,OU=$parentOU,$domaincontroller"

    if([Bool] (Get-ADUser -Filter { Name -eq $fullName })) {
        $newName = $fullName
        $newUserName = $name
        $countName = 1

        while([Bool] (Get-ADUser -Filter { Name -eq $newName })) {
            $newName += $countName
            $newUserName += $countName
            $countName++
        }

        New-ADUser `
            -SamAccountName "$fullName$count" `
            -Name "$newName" `
            -Surname $name `
            -DisplayName $fullName `
            -GivenName $firstName `
            -UserPrincipalName $fullName `
            -Path $organizationalUnitPathPeople `
            -Enabled $true `
            -Description $function `
            -ChangePasswordAtLogon $false `
            -AccountPassword (ConvertTo-SecureString "Password1234!" -AsPlainText -Force) `
            -PassThru `
    }
    else 
    {
        New-ADUser `
            -SamAccountName "$fullName$count" `
            -Name "$fullName" `
            -GivenName $firstName `
            -Surname $name `
            -DisplayName $fullName `
            -UserPrincipalName $fullName `
            -Path $organizationalUnitPathPeople `
            -Enabled $true `
            -Description $function `
            -ChangePasswordAtLogon $false `
            -AccountPassword (ConvertTo-SecureString "Password1234!" -AsPlainText -Force) `
            -PassThru `
        
        $count++
  
    }
    $globalGroupName = $unit + "_GL"
    $domainGroupName = $unit + "_DL"
    $organizationalUnitPathUnits = "OU=$unit,OU=Users,OU=$parentOU,$domaincontroller"
          
    if(-Not (Get-ADGroup -F {Name -eq $globalGroupName})) {
        New-ADGroup -Name $globalGroupName -Path $organizationalUnitPathUnits -SamAccountName $globalGroupName -GroupCategory Security -GroupScope Global
    }

    if(-Not (Get-ADGroup -F {Name -eq $domainGroupName})) {
        New-ADGroup -Name $domainGroupName -Path $organizationalUnitPathUnits -SamAccountName $domainGroupName -GroupCategory Security -GroupScope DomainLocal
    }
}

$getAllUnits = Get-ADOrganizationalUnit -Filter * -SearchBase "OU=Users,OU=$parentOU,$domaincontroller"
$getLocalGroups = Get-ADGroup -Filter "Name -like '*_GL*'" -SearchBase "OU=Users,OU=$parentOU,$domaincontroller"
$getDomainGroups = Get-ADGroup -Filter "Name -like '*_DL*'" -SearchBase "OU=Users,OU=$parentOU,$domaincontroller"

foreach($localGroup in $getLocalGroups) {
    $localGroupName = $localGroup.Name
   
    if($localGroupName.Contains("Security")) {
        Add-ADGroupMember -Members $localGroup -Identity $getDomainGroups.Item(0)
    } 
    elseif($localGroupName.Contains("Network")) {
        Add-ADGroupMember -Members $localGroup -Identity $getDomainGroups.Item(1)
    }
    elseif($localGroupName.Contains("Accounting")) {
        Add-ADGroupMember -Members $localGroup -Identity $getDomainGroups.Item(2)
    }
    else {
        Add-ADGroupMember -Members $localGroup -Identity $getDomainGroups.Item(3)
    }

}