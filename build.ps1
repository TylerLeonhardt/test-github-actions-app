[CmdletBinding()]
param (
    [Parameter()]
    [ValidateSet("Debug", "Release")]
    [string]
    $Configuration = "Debug"
)

$rid = switch ($true) {
    $IsMacOS { "osx-x64" }
    $IsLinux { 
        if ([System.IntPtr]::Size -eq 4) {
            return 'linux-x32' 
        }
        'linux-x64'
    }
    Default {
        if ([System.IntPtr]::Size -eq 4) {
            return 'win-x32' 
        }
        'win-x64'
    }
}

# Only build for the platform that we're on.
dotnet publish "$PSScriptRoot/test-github-actions-app.sln" --configuration $Configuration --runtime $rid

# Remove out if it already exists and recreate.
if (Test-Path "$PSScriptRoot/out") {
    Remove-Item -Recurse -Force "$PSScriptRoot/out"
}
New-Item -ItemType Directory -Path "$PSScriptRoot/out" -Force

# Copy to out.
Copy-Item "$PSScriptRoot/TestGitHubActionsApp/bin/$Configuration/netcoreapp2.2/$rid/publish/*" "$PSScriptRoot/out"
