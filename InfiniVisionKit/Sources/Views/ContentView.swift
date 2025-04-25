import SwiftUI

@available(iOS 17.0, macOS 14.0, visionOS 1.0, *)
public struct ContentView: View {
    @StateObject private var deviceManager = DeviceManager()
    @State private var selectedTab = 0
    
    public init() {}
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            DeviceListView(deviceManager: deviceManager)
                .tabItem {
                    Label("Devices", systemImage: "camera.fill")
                }
                .tag(0)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(1)
        }
        .onAppear {
            LoggingService.shared.info("ContentView appeared")
            deviceManager.startScanning()
        }
        .onDisappear {
            deviceManager.stopScanning()
        }
    }
} 