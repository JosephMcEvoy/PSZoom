# Contributing to PSZoom

Thank you for your interest in contributing to PSZoom! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Creating Cmdlets](#creating-cmdlets)
- [Testing](#testing)
- [Submitting Changes](#submitting-changes)
- [Using Claude Bot](#using-claude-bot)

## Code of Conduct

Please be respectful and constructive in all interactions. We welcome contributors of all skill levels.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR-USERNAME/PSZoom.git`
3. Create a feature branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Submit a pull request

## Development Setup

### Prerequisites

- PowerShell 5.1 or PowerShell 7+
- Git
- A Zoom account with API access (for integration testing)

### Installing Dependencies

```powershell
# Install Pester for testing
Install-Module -Name Pester -RequiredVersion 5.6.1 -Force

# Install PSScriptAnalyzer for code quality
Install-Module -Name PSScriptAnalyzer -Force
```

### Running Tests

```powershell
# Run all tests
Invoke-Pester -Path ./Tests

# Run with configuration
$config = Import-PowerShellDataFile ./pester.config.psd1
Invoke-Pester -Configuration (New-PesterConfiguration -Hashtable $config)

# Run specific test file
Invoke-Pester -Path ./Tests/Unit/Public/Users/Get-ZoomUser.Tests.ps1
```

## Coding Standards

### Naming Conventions

- **Cmdlets**: Use `Verb-ZoomNoun` format (e.g., `Get-ZoomUser`, `New-ZoomMeeting`)
- **Verbs**: Use [approved PowerShell verbs](https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands)
- **Parameters**: Use PascalCase (e.g., `$UserId`, `$MeetingId`)
- **Aliases**: Provide snake_case aliases matching Zoom API field names (e.g., `user_id`, `meeting_id`)

### File Structure

```
PSZoom/
├── Public/          # Exported cmdlets
│   ├── Account/
│   ├── Meetings/
│   ├── Users/
│   └── ...
├── Private/         # Internal helper functions
└── PSZoom.psd1     # Module manifest
```

### Code Style

```powershell
<#
.SYNOPSIS
Brief description of the cmdlet.

.DESCRIPTION
Detailed description of what the cmdlet does.

.PARAMETER ParameterName
Description of the parameter.

.OUTPUTS
Description of output type.

.LINK
https://developers.zoom.us/docs/api/rest/reference/...

.EXAMPLE
Example-Usage -Parameter 'value'
Description of what the example does.
#>

function Verb-ZoomNoun {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('parameter_name')]
        [string]$ParameterName
    )

    process {
        # Implementation
    }
}
```

## Creating Cmdlets

### Step 1: Identify the API Endpoint

Find the Zoom API endpoint you want to wrap in the [Zoom API documentation](https://developers.zoom.us/docs/api/).

### Step 2: Create the Cmdlet File

Create a new `.ps1` file in the appropriate category folder under `PSZoom/Public/`.

### Step 3: Implement the Cmdlet

```powershell
function Get-ZoomExample {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        [Alias('example_id')]
        [string]$ExampleId
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/examples/$ExampleId"
        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method GET
        Write-Output $response
    }
}
```

### Step 4: Add Tests

Create a corresponding test file in `Tests/Unit/Public/Category/`:

```powershell
BeforeAll {
    Import-Module "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1" -Force
    $script:PSZoomToken = ConvertTo-SecureString 'test' -AsPlainText -Force
    $script:ZoomURI = 'zoom.us'
}

Describe 'Get-ZoomExample' {
    Context 'When retrieving an example' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'example123' }
            }
        }

        It 'Should return example details' {
            $result = Get-ZoomExample -ExampleId 'example123'
            $result.id | Should -Be 'example123'
        }
    }
}
```

### Step 5: Update Documentation

Ensure your cmdlet has complete comment-based help including:
- `.SYNOPSIS`
- `.DESCRIPTION`
- `.PARAMETER` for each parameter
- `.LINK` to Zoom API documentation
- `.EXAMPLE` with at least one usage example

## Testing

### Unit Tests

- Mock `Invoke-ZoomRestMethod` to avoid actual API calls
- Test parameter validation
- Test pipeline support
- Test error handling

### Test Structure

```
Tests/
├── Unit/
│   ├── Public/
│   │   └── Category/
│   │       └── Cmdlet.Tests.ps1
│   └── Private/
│       └── Helper.Tests.ps1
├── Contract/
│   └── OpenApiValidation.Tests.ps1
└── Fixtures/
    └── MockResponses/
        └── response.json
```

### Running PSScriptAnalyzer

```powershell
# Check for issues
Invoke-ScriptAnalyzer -Path ./PSZoom -Recurse

# Check specific file
Invoke-ScriptAnalyzer -Path ./PSZoom/Public/Users/Get-ZoomUser.ps1
```

## Submitting Changes

### Pull Request Process

1. Ensure all tests pass
2. Run PSScriptAnalyzer and fix any errors
3. Update documentation if needed
4. Create a pull request with a clear description
5. Reference any related issues

### Commit Messages

Use clear, descriptive commit messages:

```
feat: Add Get-ZoomDashboardMeetings cmdlet

- Wraps /metrics/meetings endpoint
- Supports date range filtering
- Includes pagination support

Closes #123
```

Prefixes:
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `test:` - Test additions/changes
- `refactor:` - Code refactoring
- `chore:` - Build/CI changes

## Using Claude Bot

You can request Claude's help by creating an issue with `@claude` in the description:

1. Go to [Issues](https://github.com/JosephMcEvoy/PSZoom/issues/new)
2. Select "Claude Bot Request" template
3. Describe what you need help with
4. Include `@claude` in your request

Claude will analyze your request and create a pull request with proposed changes.

### Example Claude Request

```
@claude Please implement a new cmdlet Get-ZoomDashboardMeetings that wraps
the /metrics/meetings endpoint. Include support for:
- Date range filtering (from/to parameters)
- Meeting type filter
- Pagination
- Full details switch
```

## Questions?

- Open an [issue](https://github.com/JosephMcEvoy/PSZoom/issues) for questions
- Check the [Wiki](https://github.com/JosephMcEvoy/PSZoom/wiki) for documentation
- Review existing cmdlets for patterns and examples

Thank you for contributing to PSZoom!
