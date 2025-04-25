import SwiftUI
import InfiniVisionKit

struct ContentView: View {
    @StateObject private var deviceManager = DeviceManager()
    @StateObject private var screenCaptureService = ScreenCaptureService()
    
    var body: some View {
        #if os(iOS)
        NavigationView {
            ScreenView()
                .environmentObject(deviceManager)
                .environmentObject(screenCaptureService)
        }
        #elseif os(macOS)
        ScreenView()
            .environmentObject(deviceManager)
            .environmentObject(screenCaptureService)
            .frame(minWidth: 800, minHeight: 600)
        #else
        ScreenView()
            .environmentObject(deviceManager)
            .environmentObject(screenCaptureService)
        #endif
    }
} 