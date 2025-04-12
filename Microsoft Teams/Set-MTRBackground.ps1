<#
.SYNOPSIS
    Configures a custom background for Microsoft Teams Rooms (MTR) on a Skype Room System device.

.DESCRIPTION
    This script downloads a background image from a specified URL and applies it to the Microsoft Teams Rooms system by 
    modifying the SkypeSettings.xml file.

.NOTES
    Script Name    : Set-MTRBackground.ps1
    Version        : 1.0
    Author         : Abinash Raman
    Approved By    : [Approver's Name]
    Date           : [Date]
    Purpose        : Automates the process of setting a custom background in Microsoft Teams Rooms.

.PREREQUISITES
    - Ensure the target device has internet access to download the image.
    - The script must be executed with sufficient permissions to modify the MTR settings.
    - Verify the path to the Microsoft Teams Room LocalState directory.

.PARAMETERS
    None

.EXAMPLE
    .\Set-MTRBackground.ps1
    Runs the script to download and apply a custom background to the MTR system.

#>

# Start of Script

# Define Variables
$BackgroundUrl = "https://mtr.contoso.com/Display.png"
$LocalPath = "C:\Users\Skype\AppData\Local\Packages\Microsoft.SkypeRoomSystem_8wekyb3d8bbwe\LocalState"
$ImagePath = "$LocalPath\Display.png"
$SettingsFile = "$LocalPath\SkypeSettings.xml"
$LogFile = "$LocalPath\MTRBackgroundSetup.log"

# Function to log messages
function Write-Log {
    param (
        [string]$Message
    )
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "$Timestamp - $Message"
    Write-Host $LogEntry
    Add-Content -Path $LogFile -Value $LogEntry
}

# Start Logging
Write-Log "===== MTR Background Setup Script Started ====="

# Ensure the LocalState directory exists
if (-not (Test-Path -Path $LocalPath)) {
    Write-Log "Creating directory: $LocalPath"
    try {
        New-Item -ItemType Directory -Path $LocalPath -Force | Out-Null
        Write-Log "Directory created successfully."
    } catch {
        Write-Log "Error: Failed to create directory. $_"
        exit 1
    }
}

# Download Background Image
try {
    Write-Log "Downloading background image from $BackgroundUrl"
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($BackgroundUrl, $ImagePath)
    Write-Log "Download completed: $ImagePath"
} catch {
    Write-Log "Error: Failed to download the image. $_"
    exit 1
}

# Create or Update SkypeSettings.xml
$xmlContent = @"
<SkypeSettings>
    <Theming>
        <ThemeName>Custom</ThemeName>
        <CustomBackgroundMainFoRDisplay>Display.png</CustomBackgroundMainFoRDisplay>            
    </Theming>  
</SkypeSettings>
"@

try {
    Write-Log "Updating SkypeSettings.xml"
    $xmlContent | Set-Content -Path $SettingsFile -Force
    Write-Log "Configuration updated successfully: $SettingsFile"
} catch {
    Write-Log "Error: Failed to update SkypeSettings.xml. $_"
    exit 1
}

Write-Log "Custom background applied successfully."
Write-Log "===== MTR Background Setup Script Completed ====="

# End of Script
