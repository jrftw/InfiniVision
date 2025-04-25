import SwiftUI
import InfiniVisionKit

@main
struct InfiniVisionApp: App {
    @StateObject private var deviceManager = DeviceManager.shared
    private let logger = LoggingService.shared
    
    init() {
        logger.info("Application starting on \(deviceManager.getPlatformName())")
        setupAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(deviceManager)
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        #endif
    }
    
    private func setupAppearance() {
        #if os(iOS)
        // iOS-specific appearance setup
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
        #elseif os(macOS)
        // macOS-specific appearance setup
        NSWindow.allowsAutomaticWindowTabbing = false
        #endif
        
        logger.debug("Platform-specific appearance configured")
    }
} 