OUT-NULL
# Setting permissions for running start-up command through $PROFILE
Start-Process powershell "Set-ExecutionPolicy Unrestricted" -Verb runAs

# Installing Dependencies
winget update --all
winget install --id Starship.Starship
winget install --id Microsoft.VisualStudioCode.Insiders
winget install --id Microsoft.PowerToys

# Add this line to $PROFILE for persistant use of starship
if(!(Test-Path $PROFILE)){
    New-Item -type file -path $PROFILE -force
}
if(!(Select-String -Path $PROFILE -Pattern "Invoke-Expression (&starship init powershell)" -SimpleMatch -Quiet)){
    Add-Content -Path $PROFILE -Value "Invoke-Expression (&starship init powershell)"
}
