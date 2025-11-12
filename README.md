# MVVMC SD Demo

A UIKit-based iOS portfolio holdings screen built with MVVM + Coordinator and programmatic UI. The app consumes a mock API, calculates derived P&L metrics, and supports offline caching plus graceful loading/error states.

## Features

- **Architecture**: MVVM with a Coordinator and DI container for loose coupling and testability.
- **Networking**: Async/await `HoldingsAPIService` with URLSession abstraction, JSON decoding, and production/offline fallback.
- **Caching**: Disk-backed cache and bundled JSON to keep data available when offline.
- **UI**:
  - Programmatic UIKit layout, custom table cell, expandable summary footer, pull-to-refresh.
  - Loading spinner, error messaging, and retry logic.
  - P&L formatting with colour cues.
- **Testing**: Unit tests for view-model calculations and API service fallback behaviour.
- **Tooling**: Swift 5.10, Xcode 16.1 project, iOS 15.6+ target.

## Requirements

- Xcode 16.1 (or newer)
- iOS 15.6 deployment target
- Swift 5.10 toolchain

## Getting Started

1. Clone the repo:

   ```bash
   git clone https://github.com/Satyam2243Swift/MVVMC-SD-Demo.git
   cd MVVMC-SD-Demo
   ```

2. Open `MVVMC_SD_Demo.xcodeproj` in Xcode.
3. Select the `MVVMC_SD_Demo` scheme, choose an iOS 16 simulator, and run (⌘R).
4. To run tests: Product ▸ Test (⌘U) or `xcodebuild test`.

## Project Structure

```
MVVMC_SD_Demo/
├─ AppDelegate.swift / SceneDelegate.swift
├─ Coordinators/
├─ DependencyInjection/
├─ Extensions/
├─ Models/
├─ Networking/
├─ ViewModels/
├─ Views/
├─ Resources/
└─ MVVMC_SD_DemoTests/
```
