# Define variables
$domain = 'CONTOSO'
$domainUsers = $domain + '\Domain Users'
$outputFolder = 'C:\Temp\'
$githubRepo = 'https://raw.githubusercontent.com/PacktPublishing/Microsoft-Defender-for-Identity-in-Depth/main/Chapter01/LabDeployment/ESCs/'
$templates = @(
    'ESC1.json',
    'ESC2.json',
    'ESC3-1.json',
    'ESC3-2.json',
    'ESC4.json',
    'ESC5.json'
)

# Install and import the required modules
$requiredModules = @('ADCSTemplates', 'PSPKI')
foreach ($module in $requiredModules) {
    if (-not (Get-Module -Name $module -ErrorAction SilentlyContinue)) {
        Install-Module -Name $module -Force -AllowClobber
    }
    Import-Module -Name $module
}

# Download all ESC templates from the public GitHub repository and save them to the output folder
foreach ($template in $templates) {
    $url = $githubRepo + $template
    $outputFile = $outputFolder + $template
    Invoke-WebRequest -Uri $url -OutFile $outputFile
}

# Create the vulnerable certificate templates with New-ADCSTemplate (from the ADCSTemplates module)
Set-Location -Path $outputFolder
foreach ($template in $templates) {
    New-ADCSTemplate -DisplayName $template.Replace('.json', '') -JSON (Get-Content $template -Raw) -Publish -Identity $domainUsers -AutoEnroll
}

# Configure CA security settings (with PSPKI module)
$domainUsers = New-Object System.Security.Principal.NTAccount($domainUsers)
$ca = Get-CA

$issueManageCertsACE = New-Object SysadminsLV.PKI.Security.AccessControl.CertSrvAccessRule (
    $domainUsers,
    "ManageCertificates",
    "Allow"
)

$manageCAACE = New-Object SysadminsLV.PKI.Security.AccessControl.CertSrvAccessRule (
    $domainUsers,
    "ManageCA",
    "Allow"
)

$ca | Get-CASecurityDescriptor | Add-CertificationAuthorityAcl -AccessRule $issueManageCertsACE | Set-CertificationAuthorityAcl -RestartCA
$ca | Get-CASecurityDescriptor | Add-CertificationAuthorityAcl -AccessRule $manageCAACE | Set-CertificationAuthorityAcl -RestartCA
