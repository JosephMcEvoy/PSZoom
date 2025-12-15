# CLAUDE.md - PSZoom Project Guide

This file provides guidance for Claude Code when working on the PSZoom project.

## Project Overview

PSZoom is a PowerShell module that provides cmdlets for interacting with the Zoom API. It includes 263+ public functions covering Meetings, Webinars, Users, Phone, Cloud Recording, and more.

## Running Tests

### Quick Commands

```powershell
# Run unit tests (fast, no coverage)
./Invoke-Tests.ps1 -NoCoverage

# Run unit tests with code coverage
./Invoke-Tests.ps1

# Run specific test types
./Invoke-Tests.ps1 -TestType Unit         # Unit tests only (default)
./Invoke-Tests.ps1 -TestType Integration  # Integration tests (requires Zoom API credentials)
./Invoke-Tests.ps1 -TestType Contract     # Contract tests (OpenAPI validation)
./Invoke-Tests.ps1 -TestType All          # All tests
```

### Test Infrastructure

| Component | Location |
|-----------|----------|
| Test Runner | `./Invoke-Tests.ps1` |
| Unit Tests | `./Tests/Unit/` |
| Integration Tests | `./Tests/Integration/` |
| Contract Tests | `./Tests/Contract/` |
| Mock Fixtures | `./Tests/Fixtures/MockResponses/` |
| Test Helpers | `./Tests/Helpers/ZoomTestHelper.psm1` |

### Pester Configuration Files

- `pester.config.psd1` - Unit test configuration
- `pester.integration.config.psd1` - Integration test configuration
- `pester.contract.config.psd1` - Contract test configuration

### Running the Build Pipeline

```powershell
# Run full build pipeline (Test -> Build -> Deploy)
./Build/Start-Build.ps1

# Run specific tasks
./Build/Start-Build.ps1 -Task Init    # Initialize build environment
./Build/Start-Build.ps1 -Task Test    # Run tests only
./Build/Start-Build.ps1 -Task Build   # Run tests and build
./Build/Start-Build.ps1 -Task Deploy  # Full pipeline (default)
```

## Project Structure

```
PSZoom/
├── PSZoom/                 # Main module directory
│   ├── Public/            # Public cmdlets (263+ functions)
│   ├── Private/           # Private helper functions
│   └── PSZoom.psd1        # Module manifest
├── Tests/                  # Pester 5 test suite
│   ├── Unit/              # Unit tests (mocked API calls)
│   ├── Integration/       # Integration tests (live API)
│   ├── Contract/          # OpenAPI contract validation
│   └── Fixtures/          # Mock response data
├── Build/                  # Build automation
│   ├── Private/           # Build helper functions
│   ├── psake.ps1          # Build tasks
│   ├── deploy.psdeploy.ps1
│   └── Start-Build.ps1    # Build entry point
├── Invoke-Tests.ps1       # Unified test runner
└── docs/plans/            # Implementation plans
```

## Code Style

- PowerShell functions follow Verb-Noun naming convention
- Public functions are in individual files under `PSZoom/Public/`
- Tests use Pester 5 syntax with `BeforeAll`, `Describe`, `Context`, `It`
- All API calls go through `Invoke-ZoomRestMethod`

## Environment Variables for Integration Tests

```powershell
$env:ZOOM_ACCOUNT_ID = "your-account-id"
$env:ZOOM_CLIENT_ID = "your-client-id"
$env:ZOOM_CLIENT_SECRET = "your-client-secret"
```

## CI/CD

- **GitHub Actions**: CI/CD platform - runs on push/PR to main branches
  - `test.yml` - Multi-platform tests (ubuntu/windows/macos), PS 7.2 & 7.4
  - `publishModule.yml` - Publishes to PowerShell Gallery on release

## Dependencies

Build dependencies (installed automatically by `Start-Build.ps1`):
- psake 4.9.0 - Build automation
- PSDeploy 1.0.5 - Deployment
- Pester 5.6.1 - Testing framework
