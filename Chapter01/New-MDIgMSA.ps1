# Create gMSA account for Microsoft Defender for Identity

## Variables
$DSA_AccountName = 'MDIGMSA'
$DSA_HostsGroupName = 'MDI-ADFS-SensorGrp'

# Create a new gMSA account
New-ADServiceAccount -Name MDIGMSA -DNSHostName $gMSA_AccountName.$env:USERDNSDOMAIN -Description "Microsoft Defender for Identity gMSA account" -KerberosEncryptionType AES256

$gMSA_AccountName.$env:USERDNSDOMAIN

New-ADGroup -Name “MDI-ADFS-SensorGrp” -GroupCategory Security -GroupScope Global -Path “OU=Servers,DC=rebeladmin,DC=com”

# Declare the identity that you want to add read access to the deleted objects container:
$Identity = 'mdiSvc01'

# If the identity is a gMSA, first to create a group and add the gMSA to it:
$groupName = 'mdiUsr01Group'
$groupDescription = 'Members of this group are allowed to read the objects in the Deleted Objects container in AD'
if(Get-ADServiceAccount -Identity $Identity -ErrorAction SilentlyContinue) {
    $groupParams = @{
        Name           = $groupName
        SamAccountName = $groupName
        DisplayName    = $groupName
        GroupCategory  = 'Security'
        GroupScope     = 'Universal'
        Description    = $groupDescription
    }
    $group = New-ADGroup @groupParams -PassThru
    Add-ADGroupMember -Identity $group -Members ('{0}$' -f $Identity)
    $Identity = $group.Name
}

# Get the deleted objects container's distinguished name:
$distinguishedName = ([adsi]'').distinguishedName.Value
$deletedObjectsDN = 'CN=Deleted Objects,{0}' -f $distinguishedName

# Take ownership on the deleted objects container:
$params = @("$deletedObjectsDN", '/takeOwnership')
C:\Windows\System32\dsacls.exe $params

# Grant the 'List Contents' and 'Read Property' permissions to the user or group:
$params = @("$deletedObjectsDN", '/G', ('{0}\{1}:LCRP' -f ([adsi]'').name.Value, $Identity))
C:\Windows\System32\dsacls.exe $params
  
# To remove the permissions, uncomment the next 2 lines and run them instead of the two prior ones:
# $params = @("$deletedObjectsDN", '/R', ('{0}\{1}' -f ([adsi]'').name.Value, $Identity))
# C:\Windows\System32\dsacls.exe $params