function Get-Resume {
    [CmdletBinding()]
    param()

    begin {
        $parentDir = if ($env:ResumeFiles) { $env:ResumeFiles } else { $env:USERPROFILE }
        $resumeFiles = Get-ChildItem -Path (Join-Path -Path $parentDir -ChildPath "Resume") -Filter "Resume-v*"
    }

    process {
        $latestVer = [version]::new()
        $latestFile = $null

        foreach ($file in $resumeFiles) {
            $versionMatch = [regex]::Match($file.Name, 'Resume-v(\d+(\.\d+)?)')
            if ($versionMatch.Success) {
                $version = [version] $versionMatch.Groups[1].Value
                if ($version -gt $latestVer) {
                    $latestVer = $version
                    $latestFile = $file.FullName
                }
            }
        }

        if ($null -ne $latestFile) {
            $resumePath = Join-Path -Path $parentDir -ChildPath "Resume.pdf"
            Copy-Item -Path $latestFile -Destination $resumePath -Force
            Write-Verbose "Latest Resume (v$latestVer) is copied successfully to $parentDir"
            Start-Process $resumePath
        } else {
            Write-Host "No resume files found matching the pattern."
        }
    }
}

Export-ModuleMember -Function Get-Resume