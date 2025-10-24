# SyncroSim and BurnP3+ Automated Installation Script for Windows Server
# This script installs SyncroSim Studio, BurnP3+, and BurnP3+Cell2Fire

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "SyncroSim BurnP3+ Installation Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Set error action preference
$ErrorActionPreference = "Stop"

# Function to download files
function Download-File {
    param (
        [string]$Url,
        [string]$Output
    )
    Write-Host "Downloading from $Url..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $Url -OutFile $Output -UseBasicParsing
    Write-Host "Downloaded to $Output" -ForegroundColor Green
}

# Function to check if software is installed
function Test-ProgramInstalled {
    param (
        [string]$ProgramName
    )
    $installed = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
                 Where-Object { $_.DisplayName -like "*$ProgramName*" }
    return $installed -ne $null
}

# Create temporary directory
$tempDir = "$env:TEMP\SyncroSimInstall"
if (-not (Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir | Out-Null
}
Set-Location $tempDir

Write-Host ""
Write-Host "Step 1: Installing SyncroSim Studio" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Check if SyncroSim is already installed
if (Test-ProgramInstalled "SyncroSim") {
    Write-Host "SyncroSim is already installed. Skipping installation." -ForegroundColor Green
} else {
    # Download SyncroSim installer
    # Note: You'll need to update this URL with the actual SyncroSim 3.0.9+ download link
    $syncrosimUrl = "https://syncrosim.com/download/SyncroSim-3.0.9.exe"
    $syncrosimInstaller = "$tempDir\SyncroSim-Setup.exe"

    Write-Host "Downloading SyncroSim installer..." -ForegroundColor Yellow
    Write-Host "NOTE: If this fails, manually download from https://syncrosim.com/download/" -ForegroundColor Yellow

    try {
        Download-File -Url $syncrosimUrl -Output $syncrosimInstaller

        Write-Host "Running SyncroSim installer..." -ForegroundColor Yellow
        Start-Process -FilePath $syncrosimInstaller -ArgumentList "/SILENT" -Wait
        Write-Host "SyncroSim installed successfully!" -ForegroundColor Green
    } catch {
        Write-Host "Automatic download failed. Please:" -ForegroundColor Red
        Write-Host "1. Open browser and go to: https://syncrosim.com/download/" -ForegroundColor Yellow
        Write-Host "2. Download 'SyncroSim for Windows'" -ForegroundColor Yellow
        Write-Host "3. Run the installer manually" -ForegroundColor Yellow
        Write-Host "4. Then run this script again" -ForegroundColor Yellow
        exit 1
    }
}

Write-Host ""
Write-Host "Step 2: Installing Miniconda (for Python/R environments)" -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan

# Check if Miniconda is installed
$condaPath = "$env:USERPROFILE\Miniconda3\Scripts\conda.exe"
if (Test-Path $condaPath) {
    Write-Host "Miniconda is already installed. Skipping installation." -ForegroundColor Green
} else {
    # Download Miniconda
    $minicondaUrl = "https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe"
    $minicondaInstaller = "$tempDir\Miniconda3-Setup.exe"

    Download-File -Url $minicondaUrl -Output $minicondaInstaller

    Write-Host "Running Miniconda installer..." -ForegroundColor Yellow
    Start-Process -FilePath $minicondaInstaller -ArgumentList "/InstallationType=JustMe /RegisterPython=0 /S /D=$env:USERPROFILE\Miniconda3" -Wait
    Write-Host "Miniconda installed successfully!" -ForegroundColor Green

    # Add conda to PATH for current session
    $env:Path = "$env:USERPROFILE\Miniconda3;$env:USERPROFILE\Miniconda3\Scripts;$env:Path"
}

Write-Host ""
Write-Host "Step 3: Locating SyncroSim Installation" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Find SyncroSim Studio executable
$syncrosimPaths = @(
    "$env:ProgramFiles\SyncroSim Studio\SyncroSim.Studio.exe",
    "${env:ProgramFiles(x86)}\SyncroSim Studio\SyncroSim.Studio.exe",
    "$env:LOCALAPPDATA\SyncroSim\SyncroSim.Studio.exe"
)

$syncrosimExe = $null
foreach ($path in $syncrosimPaths) {
    if (Test-Path $path) {
        $syncrosimExe = $path
        break
    }
}

if ($syncrosimExe) {
    Write-Host "Found SyncroSim Studio at: $syncrosimExe" -ForegroundColor Green
} else {
    Write-Host "Could not locate SyncroSim Studio. Please install manually from:" -ForegroundColor Red
    Write-Host "https://syncrosim.com/download/" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "Step 4: Creating Desktop Shortcut" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan

# Create desktop shortcut
$desktopPath = [Environment]::GetFolderPath("Desktop")
$shortcutPath = "$desktopPath\SyncroSim Studio.lnk"

$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($shortcutPath)
$Shortcut.TargetPath = $syncrosimExe
$Shortcut.Description = "SyncroSim Studio - BurnP3+"
$Shortcut.Save()

Write-Host "Desktop shortcut created!" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Installation Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Double-click 'SyncroSim Studio' icon on desktop" -ForegroundColor White
Write-Host "2. Go to File > Local Packages..." -ForegroundColor White
Write-Host "3. Click 'Install from Server...'" -ForegroundColor White
Write-Host "4. Select 'burnP3Plus' and click OK" -ForegroundColor White
Write-Host "5. When prompted, install Miniconda (Yes)" -ForegroundColor White
Write-Host "6. When prompted, create conda environment (Yes)" -ForegroundColor White
Write-Host "7. Wait for installation to complete" -ForegroundColor White
Write-Host "8. Repeat steps 3-4 for 'burnP3PlusCell2Fire'" -ForegroundColor White
Write-Host ""
Write-Host "Alternative: Manual Package Installation" -ForegroundColor Yellow
Write-Host "If automatic package installation doesn't work in SyncroSim Studio:" -ForegroundColor White
Write-Host "- Download packages from: https://github.com/BurnP3/BurnP3Plus/releases" -ForegroundColor White
Write-Host "- In SyncroSim: File > Local Packages > Install from Folder" -ForegroundColor White
Write-Host ""
Write-Host "Documentation:" -ForegroundColor Yellow
Write-Host "- BurnP3+ Tutorial: https://burnp3.github.io/BurnP3Plus/getting_started.html" -ForegroundColor White
Write-Host "- SyncroSim Docs: https://docs.syncrosim.com/" -ForegroundColor White
Write-Host ""
Write-Host "Temporary files in: $tempDir" -ForegroundColor Gray
Write-Host "You can delete this folder after installation is verified." -ForegroundColor Gray
Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Cyan
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
