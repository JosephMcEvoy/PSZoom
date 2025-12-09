<#
.SYNOPSIS
    Generates GitHub Wiki documentation from PSZoom cmdlet help.

.DESCRIPTION
    This script extracts comment-based help from all PSZoom public cmdlets and generates
    markdown files suitable for GitHub Wiki. It creates:
    - Home.md - Index page with categorized cmdlet links
    - _Sidebar.md - Navigation sidebar
    - Individual .md file for each cmdlet

.PARAMETER ModulePath
    Path to the PSZoom module manifest (.psd1) file.
    Default: PSZoom/PSZoom.psd1

.PARAMETER OutputPath
    Path where wiki markdown files will be generated.
    Default: wiki/

.PARAMETER IncludePrivate
    If specified, also generates documentation for private functions.

.EXAMPLE
    .\Export-WikiDocumentation.ps1
    Generates wiki documentation using default paths.

.EXAMPLE
    .\Export-WikiDocumentation.ps1 -OutputPath "C:\wiki-output"
    Generates wiki documentation to a specific directory.

.EXAMPLE
    .\Export-WikiDocumentation.ps1 -ModulePath ".\PSZoom\PSZoom.psd1" -OutputPath ".\docs"
    Generates documentation with custom paths.

.NOTES
    This script is designed to be run as part of the CI/CD pipeline
    to keep wiki documentation in sync with code changes.
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$ModulePath = "$PSScriptRoot/../PSZoom/PSZoom.psd1",

    [Parameter()]
    [string]$OutputPath = "$PSScriptRoot/../wiki",

    [Parameter()]
    [switch]$IncludePrivate
)

# Ensure output directory exists
if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
    Write-Verbose "Created output directory: $OutputPath"
}

# Import the module
Write-Host "Importing PSZoom module from: $ModulePath"
Import-Module $ModulePath -Force -ErrorAction Stop

# Get all exported functions
$commands = Get-Command -Module PSZoom -CommandType Function | Sort-Object Name
Write-Host "Found $($commands.Count) commands to document"

# Organize commands by category (based on file path)
$categories = @{}

foreach ($cmd in $commands) {
    $cmdPath = $cmd.ScriptBlock.File

    if ($cmdPath -match '\\Public\\(.+?)\\') {
        $category = $Matches[1]
        # Handle nested categories (e.g., Phone/AutoReceptionist)
        $category = $category -replace '\\', '/'
    } else {
        $category = 'Utils'
    }

    if (-not $categories.ContainsKey($category)) {
        $categories[$category] = @()
    }
    $categories[$category] += $cmd.Name
}

# Generate Home.md (index page)
Write-Host "Generating Home.md..."
$homeContent = @"
# PSZoom Wiki

PowerShell wrapper for Zoom REST API v2.

## Quick Start

### Installation

``````powershell
# Install from PowerShell Gallery
Install-Module -Name PSZoom

# Import the module
Import-Module PSZoom
``````

### Authentication

``````powershell
# Connect using Server-to-Server OAuth
Connect-PSZoom -AccountID 'your_account_id' -ClientID 'your_client_id' -ClientSecret 'your_client_secret'

# Or use an existing token
Connect-PSZoom -Token 'your_access_token'
``````

### Basic Usage

``````powershell
# Get all users
Get-ZoomUser

# Get a specific user
Get-ZoomUser -UserId 'user@example.com'

# Get meeting details
Get-ZoomMeeting -MeetingId 1234567890

# Create a new meeting
New-ZoomMeeting -UserId 'user@example.com' -Topic 'Team Meeting' -Duration 60
``````

## Cmdlet Reference

| Category | Cmdlet Count |
|----------|--------------|
"@

# Add category summary table
foreach ($cat in ($categories.Keys | Sort-Object)) {
    $count = $categories[$cat].Count
    $homeContent += "`n| [$cat](#$($cat.ToLower() -replace '[/\s]', '-')) | $count |"
}

$homeContent += "`n`n---`n"

# Add detailed category sections
foreach ($cat in ($categories.Keys | Sort-Object)) {
    $homeContent += "`n## $cat`n`n"
    $homeContent += "| Cmdlet | Description |`n"
    $homeContent += "|--------|-------------|`n"

    foreach ($cmdName in ($categories[$cat] | Sort-Object)) {
        $help = Get-Help $cmdName -ErrorAction SilentlyContinue
        $synopsis = if ($help.Synopsis) {
            ($help.Synopsis -replace '\r?\n', ' ').Trim()
            if ($synopsis.Length -gt 80) {
                $synopsis = $synopsis.Substring(0, 77) + "..."
            }
        } else {
            "No description available"
        }
        $homeContent += "| [$cmdName]($cmdName) | $synopsis |`n"
    }
}

$homeContent += @"

---

## Additional Resources

- [Zoom REST API Documentation](https://developers.zoom.us/docs/api/)
- [PSZoom on PowerShell Gallery](https://www.powershellgallery.com/packages/PSZoom)
- [PSZoom GitHub Repository](https://github.com/JosephMcEvoy/PSZoom)
- [Report Issues](https://github.com/JosephMcEvoy/PSZoom/issues)

---

*Documentation auto-generated from PSZoom module help.*
"@

$homeContent | Out-File -FilePath "$OutputPath/Home.md" -Encoding UTF8
Write-Host "Created: Home.md"

# Generate _Sidebar.md (navigation)
Write-Host "Generating _Sidebar.md..."
$sidebarContent = @"
# PSZoom

- [Home](Home)
- [Getting Started](Home#quick-start)

## Cmdlets by Category

"@

foreach ($cat in ($categories.Keys | Sort-Object)) {
    $sidebarContent += "`n### $cat`n`n"
    foreach ($cmdName in ($categories[$cat] | Sort-Object)) {
        $sidebarContent += "- [$cmdName]($cmdName)`n"
    }
}

$sidebarContent | Out-File -FilePath "$OutputPath/_Sidebar.md" -Encoding UTF8
Write-Host "Created: _Sidebar.md"

# Generate individual cmdlet pages
Write-Host "Generating individual cmdlet documentation..."
$generatedCount = 0

foreach ($cmd in $commands) {
    $cmdName = $cmd.Name
    $help = Get-Help $cmdName -Full -ErrorAction SilentlyContinue

    if (-not $help) {
        Write-Warning "No help found for: $cmdName"
        continue
    }

    $markdown = @"
# $cmdName

## Synopsis

$($help.Synopsis)

## Description

$(if ($help.Description) { $help.Description.Text } else { "No detailed description available." })

## Syntax

``````powershell
"@

    # Add syntax
    if ($help.Syntax) {
        $syntaxText = ($help.Syntax | Out-String).Trim()
        $markdown += "`n$syntaxText`n"
    }

    $markdown += "```````n`n"

    # Add parameters section
    if ($help.Parameters.Parameter) {
        $markdown += "## Parameters`n`n"

        foreach ($param in $help.Parameters.Parameter) {
            $markdown += "### -$($param.Name)`n`n"

            if ($param.Description) {
                $markdown += "$($param.Description.Text)`n`n"
            }

            $markdown += "| Property | Value |`n"
            $markdown += "|----------|-------|`n"
            $markdown += "| Type | ``$($param.Type.Name)`` |`n"
            $markdown += "| Required | $($param.Required) |`n"
            $markdown += "| Position | $($param.Position) |`n"
            $markdown += "| Default value | $(if ($param.DefaultValue) { $param.DefaultValue } else { 'None' }) |`n"
            $markdown += "| Accept pipeline input | $($param.PipelineInput) |`n"
            $markdown += "`n"
        }
    }

    # Add examples section
    if ($help.Examples.Example) {
        $markdown += "## Examples`n`n"

        $exampleNum = 1
        foreach ($example in $help.Examples.Example) {
            $title = $example.Title -replace '-+', '' -replace 'EXAMPLE \d+', "Example $exampleNum"
            $markdown += "### $title`n`n"

            if ($example.Introduction) {
                $markdown += "$($example.Introduction.Text)`n`n"
            }

            $markdown += "``````powershell`n"
            $markdown += "$($example.Code)`n"
            $markdown += "```````n`n"

            if ($example.Remarks) {
                $remarks = ($example.Remarks | Out-String).Trim()
                if ($remarks) {
                    $markdown += "$remarks`n`n"
                }
            }

            $exampleNum++
        }
    }

    # Add outputs section
    if ($help.ReturnValues) {
        $markdown += "## Outputs`n`n"
        $outputText = ($help.ReturnValues | Out-String).Trim()
        if ($outputText) {
            $markdown += "$outputText`n`n"
        }
    }

    # Add related links section
    if ($help.RelatedLinks.NavigationLink) {
        $markdown += "## Related Links`n`n"

        foreach ($link in $help.RelatedLinks.NavigationLink) {
            if ($link.Uri) {
                $linkText = if ($link.LinkText) { $link.LinkText } else { $link.Uri }
                $markdown += "- [$linkText]($($link.Uri))`n"
            } elseif ($link.LinkText) {
                # Internal link to another cmdlet
                $markdown += "- [$($link.LinkText)]($($link.LinkText))`n"
            }
        }
        $markdown += "`n"
    }

    # Footer
    $markdown += @"

---

*Documentation auto-generated from $cmdName help.*
"@

    # Write the file
    $filePath = "$OutputPath/$cmdName.md"
    $markdown | Out-File -FilePath $filePath -Encoding UTF8
    $generatedCount++
    Write-Verbose "Created: $cmdName.md"
}

Write-Host "`nWiki documentation generated successfully!"
Write-Host "  Output directory: $OutputPath"
Write-Host "  Files generated: $($generatedCount + 2) (Home.md, _Sidebar.md, + $generatedCount cmdlet pages)"
Write-Host "`nTo use with GitHub Wiki:"
Write-Host "  1. Clone your wiki: git clone https://github.com/JosephMcEvoy/PSZoom.wiki.git"
Write-Host "  2. Copy files from '$OutputPath' to the wiki directory"
Write-Host "  3. Commit and push the changes"
