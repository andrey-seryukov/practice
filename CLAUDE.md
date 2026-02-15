# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Practice is an iOS timer app built with SwiftUI targeting iOS 17+. Bundle ID: `net.ycode.Practice`.

## Build & Test Commands

```bash
# Build
xcodebuild -project Practice.xcodeproj -scheme Practice -destination 'platform=iOS Simulator,name=iPhone 17' build

# Run tests
xcodebuild -project Practice.xcodeproj -scheme Practice -destination 'platform=iOS Simulator,name=iPhone 17' test

# Build (quiet mode)
xcodebuild -project Practice.xcodeproj -scheme Practice -destination 'platform=iOS Simulator,name=iPhone 17' -quiet build
```

## Architecture

- **UI Framework:** SwiftUI
- **Swift Version:** 6.0
- **Test Framework:** Swift Testing (`import Testing`)
- **Project format:** Xcode project with file system synchronized groups (objectVersion 77) — source files in `Practice/` and `PracticeTests/` are automatically tracked by Xcode without manual pbxproj edits
