import Foundation
import SwiftUI

// Export all public components
public struct InfiniVisionKit {
    public static let version = "1.0.0"
}

// Re-export key components
@available(iOS 17.0, macOS 14.0, visionOS 1.0, *)
public typealias InfiniVisionView = ContentView
public typealias InfiniVisionDeviceManager = DeviceManager
public typealias InfiniVisionLogger = LoggingService 