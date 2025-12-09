# Changelog

All notable changes to PSZoom will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Comprehensive test suite with Pester 5.6.1
- Unit tests for all Private helper functions
- Unit tests for Utils functions (Connect-PSZoom, Invoke-ZoomRestMethod, etc.)
- Sample unit tests for public cmdlets (Get-ZoomUser, Get-ZoomMeeting)
- Mock response JSON fixtures for testing
- GitHub Actions test workflow with multi-platform support
- Code coverage tracking with Codecov integration
- GitHub Wiki documentation automation
- Claude bot integration for automated issue remediation
- GitHub issue templates (bug report, feature request, Claude request)
- Pull request template
- CONTRIBUTING.md guidelines
- CHANGELOG.md

### Changed
- Upgraded Pester from 4.10.1 to 5.6.1
- Updated GitHub Actions to use latest action versions (v4)
- Enhanced PSScriptAnalyzer workflow with comprehensive analysis
- Updated publishModule workflow with test validation step
- Improved .gitignore for test artifacts

### Infrastructure
- New `Tests/` directory structure mirroring `PSZoom/Public/`
- `pester.config.psd1` for Pester 5 configuration
- `Build/Export-WikiDocumentation.ps1` for wiki generation
- `.github/workflows/test.yml` for CI testing
- `.github/workflows/wiki-sync.yml` for documentation sync
- `.github/workflows/claude-bot.yml` for AI-assisted development

## [2.1] - Previous Release

### Cmdlet Categories
- Account (3 cmdlets)
- CloudRecording (8 cmdlets)
- Groups (12 cmdlets)
- IMGroups (1 cmdlet)
- Meetings (24 cmdlets)
- Phone (50+ cmdlets)
- PhoneSite (3 cmdlets)
- Reports (7 cmdlets)
- Rooms (11 cmdlets)
- Users (22 cmdlets)
- Utils (4 cmdlets)
- Webinars (3 cmdlets)

## [2.0] - OAuth Update

### Changed
- Migrated from JWT authentication to Server-to-Server OAuth
- Updated Connect-PSZoom to use OAuth 2.0
- Added New-OAuthToken for token generation

### Added
- Support for Zoomgov.com API endpoint
- APIConnection parameter for Zoom environment selection

## [1.x] - Initial Releases

### Added
- Initial PowerShell module for Zoom API
- JWT authentication support
- Core cmdlets for users, meetings, groups, and recordings

---

## Version History Quick Reference

| Version | Date | Highlights |
|---------|------|------------|
| 3.0.0 | TBD | Full API coverage, comprehensive tests, Wiki docs, Claude bot |
| 2.1 | 2024 | Bug fixes and enhancements |
| 2.0 | 2022 | OAuth 2.0 migration |
| 1.x | 2019-2021 | Initial releases with JWT auth |
