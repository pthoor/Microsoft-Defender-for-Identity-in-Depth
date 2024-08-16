Function Install-MDI {

    Param (
        [System.String]$SourceFilesFullPath,

        [Parameter(Mandatory = $true)]
        [bool]$NetFramework,

        [Parameter(Mandatory = $true)]
        $AccessKey,

        $DelayedUpdate,

        $LogPath,

        $ProxyURL,
        $ProxyUserName,
        $ProxyPassword

    )


    # Install the package
    if (-not (Test-Path "$SourceFilesFullPath\Azure ATP Sensor Setup.exe" -ErrorAction SilentlyContinue)) {
        Write-Log -msg "Azure ATP Sensor Setup.exe file not found. Exiting... " -msgtype ERROR
        exit
    }
    Write-Log -msg "Installing Microsoft Defender for Identity sensor" -msgtype INFO
    Set-Location $workfolder
    $exitCode = (Start-Process -FilePath "$SourceFilesFullPath\Azure ATP Sensor Setup.exe" -ArgumentList @("/quiet", "NetFrameworkCommandLineArguments='/q'") -Wait -Passthru).ExitCode
    $message = (net helpmsg $exitCode)
    if ($exitCode -ne 0) {

        Write-Log -msg "Installation failed: $message. See log files in %LocalAppData% for additional details" -msgtype ERROR
        throw $message
    }
    else {
        Write-Log -msg "Microsoft Defender for Identity sensor installed. $message" -msgtype INFO
    }
}

Function Write-Log {
    Param (
        [System.String]$msg,
    
        [ValidateSet("INFO", "ERROR", "WARNING")]
        [System.String]$msgtype,

        [switch]$Force
    )
    if ($PSBoundParameters.ContainsKey("Force")) {
        Write-Output -InputObject "$(Get-Date -Format ("[yyyy-MM-dd][HH:mm:ss]")) $msgtype $msg" | Out-File $logpath
    }
    else {
        Write-Output -InputObject "$(Get-Date -Format ("[yyyy-MM-dd][HH:mm:ss]")) $msgtype $msg" | Out-File $logpath -Append
    }
}

Write-Log -msg "=========================================" -msgtype INFO
Write-Log -msg "Starting Microsoft Defender for Identity installation process ..." -msgtype INFO
Write-Log -msg "Sources full path: $SourceFilesFullPath" -msgtype INFO