## Look in the %LocalAppDaya%\temp\ folder for the MDI installation log file
## Look for file called with todays date: Azure Advanced Threat Protection Sensor_20240214062046_000_MsiPackage
## Look for MSI (s) (90:9C) [07:14:38:171]: Product: Azure Advanced Threat Protection Sensor -- Installation completed successfully.
## MSI (s) (90:9C) [07:14:38:171]: Windows Installer installed the product. Product Name: Azure Advanced Threat Protection Sensor. Product Version: 2.228.17612.22841. Product Language: 1033. Manufacturer: Microsoft Corporation. Installation success or error status: 0.


# Get-MDIInstallCode.ps1

# Get the installation code from the MDI installation log file
$MDIInstallLog = Get-ChildItem -Path "$env:LocalAppData\Temp" -Filter "Azure Advanced Threat Protection Sensor_$(Get-Date -Format "yyyyMMdd")*.log" -Recurse -ErrorAction SilentlyContinue | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 1
if ($MDIInstallLog -eq $null) {
    Write-Output "MDI installation log file not found"
    exit
}

$MDIInstallCode = Get-Content -Path $MDIInstallLog.FullName | Select-String -Pattern "Installation completed successfully" -Context 0,1
if ($MDIInstallCode -eq $null) {
    Write-Output "MDI installation code not found"
    exit
}

# Extract the product version found in the same logfile, the row looks like this - MSI (s) (90:9C) [07:14:38:171]: Windows Installer installed the product. Product Name: Azure Advanced Threat Protection Sensor. Product Version: 2.228.17612.22841. Product Language: 1033. Manufacturer: Microsoft Corporation. Installation success or error status: 0.
$MDIProductVersion = Get-Content -Path $MDIInstallLog.FullName | Select-String -Pattern "Product Version:" | ForEach-Object { $_ -replace "Product Version: ", "" }
$MDIProductVersion = $MDIProductVersion -replace "`r`n", ""
$MDIProductVersion = $MDIProductVersion[1].Trim()


# Output the results
Write-Output "MDI installation code: $MDIInstallCode"
Write-Output "MDI product version: $MDIProductVersion"