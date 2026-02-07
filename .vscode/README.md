# VS Code Quick Start

## Open Project
```bash
code /path/to/AdaptiveCards-Mobile
```

## Run Tests (Keyboard)
Press: `⇧⌘P` (Command Palette)
Type: `Tasks: Run Task`
Select: `Test All Platforms`

## Run Tests (Terminal)
Press: `⌃\`` (Open Terminal)
```bash
# iOS
cd ios && swift test

# Android  
cd android && gradle test
```

## Expected Results
- iOS: 40+ tests pass in ~2 seconds
- Android: 12+ tests pass in ~3 seconds

## Status
✅ Ready to test - all configurations in place!
