import Foundation
import SwiftUI

public class DeviceManager: ObservableObject {
    public static let shared = DeviceManager()
    
    @Published public private(set) var isVisionOS: Bool
    @Published public private(set) var isMacOS: Bool
    @Published public private(set) var isIOS: Bool
    
    private init() {
        #if os(visionOS)
        isVisionOS = true
        isMacOS = false
        isIOS = false
        #elseif os(macOS)
        isVisionOS = false
        isMacOS = true
        isIOS = false
        #elseif os(iOS)
        isVisionOS = false
        isMacOS = false
        isIOS = true
        #endif
    }
    
    public func getPlatformName() -> String {
        if isVisionOS { return "visionOS" }
        if isMacOS { return "macOS" }
        if isIOS { return "iOS" }
        return "Unknown"
    }
} 