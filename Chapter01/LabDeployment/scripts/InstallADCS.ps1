# Define variables
$CAName = "ContosoRootCA"
$CommonName = "Contoso Root CA"
$ValidityPeriodYears = 5
$CSP = "RSA#Microsoft Software Key Storage Provider"
$KeyLength = 2048
$CRLPath = "C:\CertEnroll\"
$DatabasePath = "C:\Windows\System32\CertLog\"
$LogPath = "C:\Windows\System32\CertLog\"

# Install AD CS role
Install-WindowsFeature ADCS-Cert-Authority, ADCS-Web-Enrollment -IncludeManagementTools

# Install AD CS
Install-AdcsCertificationAuthority `
    -CAType EnterpriseRootCA `
    -CACommonName $CommonName `
    -CADistinguishedNameSuffix "DC=contoso,DC=local" `
    -CryptoProviderName $CSP `
    -KeyLength $KeyLength `
    -HashAlgorithmName "SHA256" `
    -ValidityPeriod Years `
    -ValidityPeriodUnits $ValidityPeriodYears `
    -DatabaseDirectory $DatabasePath `
    -LogDirectory $LogPath `
    -Confirm:$false


# Create a vulnerable certificate template for MDI
$TemplateName = "VulnerableTemplate"
$Template = New-CertificateTemplate `
    -Name $TemplateName `
    -ValidityPeriod "1 year" `
    -KeyLength 2048 `
    -MinimumKeyLength 1024 `
    -SignatureAlgorithm "SHA1" `
    -SubjectName "CommonName" `
    -SubjectNameSource "None"

# Enable Auditing for AD CS
auditpol /set /subcategory:"Certification Services" /success:enable /failure:enable
auditpol /set /subcategory:"Object Access" /success:enable /failure:enable
auditpol /set /subcategory:"Logon/Logoff" /success:enable /failure:enable

# Restart the AD CS service to apply the changes
Restart-Service CertSvc

Write-Host "AD CS Installation and Configuration completed successfully."
