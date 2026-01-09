<#
.SYNOPSIS
    Automated Installer for rEFInd on 2013 Mac Pro (Trash Can)
#>

# --- Configuration ---
# Update "idk" to the correct tag if it changes
$ReleaseTag     = "idk" 
$BaseUrl        = "https://github.com/ldinino/rEFInd_MacPro/releases/download/$ReleaseTag"
$ZipUrl         = "$BaseUrl/refind.zip"
$FixerUrl       = "$BaseUrl/fix_refind.bat"

$TempDir        = "$env:TEMP\rEFInd_Installer"
$MountLetter    = "S:"
$EFIDestination = "$MountLetter\EFI\refind"
$DesktopPath    = [Environment]::GetFolderPath("Desktop")

# --- 1. Admin Privilege Check ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "This script requires Administrator privileges."
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Clear-Host
Write-Host "Starting rEFInd Installation (Release Version)..." -ForegroundColor Cyan

# --- 2. Mount EFI Partition ---
Write-Host "Mounting EFI System Partition to $MountLetter..."
if (Test-Path $MountLetter) {
    mountvol $MountLetter /D
}
mountvol $MountLetter /S
if (-not (Test-Path $MountLetter)) {
    Write-Error "Failed to mount EFI partition. Exiting."
    pause
    exit
}

# --- 3. Setup Temp Directory ---
if (Test-Path $TempDir) { Remove-Item -Path $TempDir -Recurse -Force }
New-Item -ItemType Directory -Path $TempDir | Out-Null

# --- 4. Download and Install rEFInd ---
Write-Host "Downloading rEFInd binary archive..."
$ZipFile = "$TempDir\refind.zip"

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $ZipUrl -OutFile $ZipFile
}
catch {
    Write-Error "Failed to download refind.zip. Check URL or internet connection."
    mountvol $MountLetter /D
    exit
}

Write-Host "Extracting files..."
Expand-Archive -Path $ZipFile -DestinationPath $TempDir -Force

# Verify structure: refind.zip -> refind folder
$ExtractedRefind = "$TempDir\refind"

if (-not (Test-Path $ExtractedRefind)) {
    Write-Error "The zip file did not contain the expected 'refind' folder."
    mountvol $MountLetter /D
    exit
}

Write-Host "Installing rEFInd to $EFIDestination..."
if (Test-Path $EFIDestination) {
    Remove-Item -Path $EFIDestination -Recurse -Force
}
Copy-Item -Path $ExtractedRefind -Destination "$MountLetter\EFI\" -Recurse -Force

if (-not (Test-Path "$EFIDestination\refind_x64.efi")) {
    Write-Error "Critical Error: refind_x64.efi not found in destination."
    mountvol $MountLetter /D
    exit
}

# --- 5. Download Fixer Script to Desktop ---
Write-Host "Downloading fixer script to Desktop..."
$FixerDest = "$DesktopPath\fix_refind.bat"
try {
    Invoke-WebRequest -Uri $FixerUrl -OutFile $FixerDest
    Write-Host "Script saved to: $FixerDest" -ForegroundColor Green
}
catch {
    Write-Warning "Failed to download fixer script. You may need to download it manually."
}

# --- 6. Update Boot Manager (BCD) ---
Write-Host "Updating Windows Boot Manager (BCD)..."
$RefindEfiPath = "\EFI\refind\refind_x64.efi"

& bcdedit /set "{bootmgr}" path $RefindEfiPath
& bcdedit /set "{bootmgr}" description "rEFInd Boot Manager"

if ($LASTEXITCODE -eq 0) {
    Write-Host "Boot configuration updated successfully." -ForegroundColor Green
} else {
    Write-Error "Failed to update BCD."
}

# --- 7. Cleanup ---
Write-Host "Cleaning up..."
mountvol $MountLetter /D
Remove-Item -Path $TempDir -Recurse -Force

Write-Host "------------------------------------------------"
Write-Host "Installation Complete." -ForegroundColor Green
Write-Host "Reboot to test."
Write-Host "------------------------------------------------"

Pause
