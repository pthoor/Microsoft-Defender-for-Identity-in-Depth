# Define variables
$CAName = "ContosoRootCA"
$CommonName = "Contoso Root CA"
$ValidityPeriodYears = 5
$CSP = "RSA#Microsoft Software Key Storage Provider"
$KeyLength = 4096
$CRLPath = "C:\CertEnroll\"
$DatabasePath = "C:\Windows\System32\CertLog\"
$LogPath = "C:\Windows\System32\CertLog\"

# Install AD CS role
Install-WindowsFeature ADCS-Cert-Authority, ADCS-Web-Enrollment, ADCS-Online-Cert-Responder -IncludeManagementTools

# Install AD CS
Install-AdcsCertificationAuthority `
    -CAType EnterpriseRootCA `
    -CACommonName $CommonName `
    -CADistinguishedNameSuffix "DC=contoso,DC=com" `
    -CryptoProviderName $CSP `
    -KeyLength $KeyLength `
    -HashAlgorithmName "SHA256" `
    -ValidityPeriod Years `
    -ValidityPeriodUnits $ValidityPeriodYears `
    -DatabaseDirectory $DatabasePath `
    -LogDirectory $LogPath `
    -SharedFolder $CRLPath

# Configure CRL Distribution Point (CDP)
Add-CertificationAuthority -CAName $CAName -CRLPath "file://$CRLPath\$CAName.crl" -CRLFlag IncludeInAllCRLs,PublishDeltaCRLs
Set-CertificationAuthority -CAName $CAName -CRLPeriodUnits 1 -CRLPeriod "Days"

# Configure Authority Information Access (AIA)
Add-CertificationAuthority -CAName $CAName -AIAPublish "file://$CRLPath\$CAName.crt" -AIAIncludeInCert

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
