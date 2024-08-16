# Install AD CS role
Install-WindowsFeature -Name ADCS-Cert-Authority -IncludeManagementTools

# Configure AD CS
$certAuthority = "MyCertAuthority"
$certAuthorityDN = "CN=$certAuthority,CN=Public Key Services,CN=Services,CN=Configuration,DC=contoso,DC=com"
$certAuthorityPassword = "P@ssw0rd"

# Create a new AD CS configuration
$certConfig = New-Object -ComObject X509Enrollment.CX509CertificateAuthority
$certConfig.InitializeFromTemplateName("RootCA")
$certConfig.SetCertificateTemplate("RootCA")
$certConfig.SetCACommonName($certAuthority)
$certConfig.SetCASecurity($certAuthorityDN, $certAuthorityPassword, 0x80000000)

# Install the AD CS configuration
$certConfig.Install($true, $false, $false)

# Start the AD CS service
Start-Service -Name CertSvc