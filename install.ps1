# Install global Claude Code skills for Elixir/Phoenix/Ash development
# Windows PowerShell installer
#
# Usage:
#   irm https://raw.githubusercontent.com/BehedgeFund/claude-skills/main/install.ps1 | iex
#   # or
#   git clone https://github.com/BehedgeFund/claude-skills.git; cd claude-skills; .\install.ps1

$ErrorActionPreference = "Stop"

$SkillsDir = Join-Path $env:USERPROFILE ".claude\skills"

Write-Host "Installing Claude Code skills to $SkillsDir..."

# Detect source
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SourceDir = Join-Path $ScriptDir "skills"

if (-not (Test-Path $SourceDir)) {
    $TempDir = Join-Path $env:TEMP "claude-skills-$(Get-Random)"
    git clone --depth 1 https://github.com/BehedgeFund/claude-skills.git $TempDir
    $SourceDir = Join-Path $TempDir "skills"
    $Cleanup = $true
}

# Create skills directory
New-Item -ItemType Directory -Force -Path $SkillsDir | Out-Null

# Copy each skill
$Installed = 0
Get-ChildItem -Path $SourceDir -Directory | ForEach-Object {
    $SkillName = $_.Name
    $Target = Join-Path $SkillsDir $SkillName

    if (Test-Path $Target) {
        Write-Host "  Updating: $SkillName"
        Remove-Item -Recurse -Force $Target
    } else {
        Write-Host "  Installing: $SkillName"
    }

    Copy-Item -Recurse $_.FullName $Target
    $Installed++
}

if ($Cleanup) { Remove-Item -Recurse -Force $TempDir }

Write-Host ""
Write-Host "Done! Installed $Installed skills to $SkillsDir"
Write-Host ""
Write-Host "Open any Elixir project with Claude Code and run /setup-project to bootstrap it."
