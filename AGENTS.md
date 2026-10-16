## Project Overview

Mizu (水) is a macOS menu bar app that reminds users to drink water at configurable intervals.

## Coding Guidelines
- Use TDD skill for writing code.
- Use Systematic Debuggins skill for finding bugs and issues.
- Use Modularity Review and Modularity Design skills for architectural decisions.

## Build Commands

```bash
# Build the app
xcodebuild -project Mizu.xcodeproj -scheme Mizu -configuration Release

# Build for debugging
xcodebuild -project Mizu.xcodeproj -scheme Mizu -configuration Debug
```

## Release Process

See [Release Process](docs/RELEASE.md) for release instructions.
