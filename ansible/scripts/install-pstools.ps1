# Check for administrator privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "This script requires administrator privileges. Please run as administrator." -ForegroundColor Red
    exit $LASTEXITCODE
}

#Resetting previous error
$Error.Clear()

# Check if the previous error has been cleared
if ($Error.Count -gt 0) {
    Write-Host "Failed to reset previous error." -ForegroundColor Red
    Write-Host "Exiting script." -ForegroundColor Red
    exit 1
}

Write-Host "This script will install PS Tools in C:/Windows/System32" -ForegroundColor Cyan

# Download PsExec tool
$downloadUrl = "https://download.sysinternals.com/files/PSTools.zip"
$destinationPath = "$env:TEMP\PSTools.zip"

Write-Host "Downloading PSTools" -ForegroundColor Cyan

Invoke-WebRequest -Uri $downloadUrl -OutFile $destinationPath

Write-Host "Download Completed" -ForegroundColor Green
Write-Host "Unzipping PSTools" -ForegroundColor Cyan

# Unzip the downloaded file
Expand-Archive -Path $destinationPath -DestinationPath "$env:TEMP\PSTools"

Write-Host "Copying PSTools to windows executable path" -ForegroundColor Cyan
# Move the tools to C:\Windows\System32
Move-Item -Path "$env:TEMP\PSTools\*" -Destination "C:\Windows\System32" -Force

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to copy PS TOOL due to $Error. " -ForegroundColor Red
    Write-Host "Exiting with error code $LASTEXITCODE." -ForegroundColor Red
    exit $LASTEXITCODE
} else {
    Write-Host "Successfully downloaded and copied." -ForegroundColor Green
    exit 0
}