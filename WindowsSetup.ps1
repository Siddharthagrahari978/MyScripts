OUT-NULL
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe -Verb RunAs -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File $PSCommandPath")
    exit
}
Write-Host "Starting Windows Setup Script-------------------------------" -ForegroundColor Cyan

# Setting permissions for running start-up command through $PROFILE
Write-Host "Setting Execution Policy------------------------------------"
Start-Process powershell "Set-ExecutionPolicy Unrestricted" -Verb runAs
Write-Host "------------------------------------------------------------"

# Installing Winget Packages
Write-Host "Installing Dependencies-------------------------------------" -ForegroundColor Green
$packages = 
    "Starship.Starship",
    "Microsoft.VisualStudioCode",
    "OpenJS.NodeJS.LTS",
    "Git.Git",
    "Microsoft.PowerToys",
    "Microsoft.WindowsTerminal"
    "Microsoft.DotNet.SDK.8"
Invoke-Expression "winget ls" -OutVariable installedPackages | Out-Null
$installedPackages = $installedPackages -split "\s"
foreach ($package in $packages) {
    if ($installedPackages.Contains($package)) {
        Write-Host $package "already installed." -ForegroundColor Yellow
    } else {
        Write-Host "Installing" $package "..." -ForegroundColor White
        winget install --id $package
    }
}
Write-Host "------------------------------------------------------------"


# Updating Winget Pacakges
Write-Host "Updating Winget Packages------------------------------------" -ForegroundColor Green
winget update --all
Write-Host "------------------------------------------------------------"

Write-Host "Configuring for persistant use of starship------------------" -ForegroundColor Green
if(!(Test-Path $PROFILE)){
    New-Item -type file -path $PROFILE -force
}
if(!(Select-String -Path $PROFILE -Pattern "Invoke-Expression (&starship init powershell)" -SimpleMatch -Quiet)){
    Add-Content -Path $PROFILE -Value "Invoke-Expression (&starship init powershell)"
}
Write-Host "------------------------------------------------------------"

Write-Host "Installing VSCode Extensions..."
$extensions =
    "bradlc.vscode-tailwindcss",
    "dsznajder.es7-react-js-snippets",
    "github.copilot",
    "github.copilot-chat"

$cmd = "code --list-extensions"
Invoke-Expression $cmd -OutVariable output | Out-Null
$output = $output -split "\s"

foreach ($ext in $extensions) {
    if ($output.Contains($ext)) {
        Write-Host $ext "already installed." -ForegroundColor Yellow
    } else {
        Write-Host "Installing" $ext "..." -ForegroundColor White
        code --install-extension $ext
    }
}
Write-Host "------------------------------------------------------------"
Write-Host
Write-Host "Windows Setup Script Completed------------------------------" -ForegroundColor Cyan
$countdownSeconds = 10

while ($countdownSeconds -gt 0) {
    Write-Host "This will automatically close in $countdownSeconds seconds... (Press any key to cancel)" -NoNewline
    Start-Sleep -Seconds 1
    $countdownSeconds--

    if ($Host.UI.RawUI.KeyAvailable) {
        Write-Host "`nKey pressed. Closing..."
        Read-Host -Prompt "Press Enter to exit"
        exit
    }
    Write-Host "`r" -NoNewline #clear the line.
}

Write-Host "`nClosing automatically..."
Start-Sleep -Seconds 1
exit