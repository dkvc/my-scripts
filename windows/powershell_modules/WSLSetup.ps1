param(
    [switch] $Continue,
    [switch] $Verbose
)

function Test-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
    return (New-Object Security.Principal.WindowsPrincipal($currentUser)).IsInRole($adminRole)
}

if (-not (Test-Admin)) {
    Write-Host "This script must be run as an Administrator. Please run it again with elevated privileges."
    exit
}

# Check if WSL is installed
wsl --status 2>&1 | Out-Null
$wslStatus = $?

if ($wslStatus -ne $true) {
    Write-Host "WSL is not installed. Installing WSL..."
    $wslInstall = Start-Process -FilePath wsl.exe -ArgumentList "--install -d Ubuntu --no-launch" -Wait -PassThru

    # Check for successful installation
    if ($wslInstall.ExitCode -eq 0) {
        Write-Host "WSL installed successfully. Preparing for restart..."

        $scriptPath = $MyInvocation.MyCommand.Path
        $verboseSwitch = if ($Verbose) { "-Verbose" } else { "" }
        $command = "powershell.exe"
        $arguments = "-ExecutionPolicy Bypass -File `"$scriptPath`" -Continue $verboseSwitch"
        
        # $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
        # [OUTDATED] -> New-ItemProperty -Path $regPath -Name "WSLSetup" -Value $command -PropertyType String
        # This one doesnt seem to work on Windows 11 Enterprise LTSC since $regPath doesn't exist. Use TaskScheduler instead.
        $action = New-ScheduledTaskAction -Execute $command -Argument $arguments
        $trigger = New-ScheduledTaskTrigger -AtLogOn -RandomDelay 00:00:05
        $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
        Register-ScheduledTask -TaskName "WSLSetup" -Action $action -Trigger $trigger -Settings $settings -User $env:UserName -Description "Runs WSL Setup at startup once. If you can still see this task after installation, you can safely delete it." -RunLevel Highest

        # Delay
        Write-Host "Your system will restart in 5 seconds."
        Start-Sleep -Seconds 5
        # Restart
        Restart-Computer
    } else {
        Write-Host "There is an issue installing WSL on your system."
        exit
    }
} else {
    Write-Host "WSL is already installed. Skipping."  
}

if ($Continue) {
    Write-Host "Continuing WSL Installation...Setting up Ubuntu user..."
    Start-Process -FilePath "ubuntu.exe" -Wait -PassThru
    Write-Host "Ubuntu.exe opened. Please complete the user setup and close the window."
    Unregister-ScheduledTask -TaskName "WSLSetup" -Confirm:$false
}

# Get location of WSLSetup script
$wslScriptPath = "/mnt/c/Users/$env:UserName/Documents/Utils/Scripts"
$verboseParam = if ($Verbose) { "-v" } else { "" }
wsl -d "Ubuntu" -e bash -li -c "cd $wslScriptPath; chmod a+x wsl_setup_py.sh; ./wsl_setup_py.sh $verboseParam"