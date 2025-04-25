# InfiniVision

A cross-platform vision framework for iOS, macOS, and visionOS applications.

## Features

- Cross-platform support (iOS, macOS, visionOS)
- Device discovery and management
- Camera access and control
- Comprehensive logging system
- Modern SwiftUI interface

## Requirements

- iOS 17.0+
- macOS 14.0+
- visionOS 1.0+
- Xcode 16.3+
- Swift 5.9+

## Installation

### Swift Package Manager

Add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/infinitumlive/InfiniVision.git", from: "1.0.0")
]
```

Or add it through Xcode's package manager.

## Usage

```swift
import InfiniVisionKit

// Initialize the framework
let deviceManager = DeviceManager()

// Start scanning for devices
deviceManager.startScanning()

// Access discovered devices
let devices = deviceManager.discoveredDevices
```

## Documentation

For detailed documentation, please visit our [documentation website](https://infinitumlive.com/docs).

## Support

For support, please contact us at [support@infinitumlive.com](mailto:support@infinitumlive.com).

## License

InfiniVision is available under the MIT license. See the LICENSE file for more info.

## Website

Visit our website at [infinitumlive.com](https://infinitumlive.com) for more information about our products and services. 