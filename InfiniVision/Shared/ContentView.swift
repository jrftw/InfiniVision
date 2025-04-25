import SwiftUI
import InfiniVisionKit

struct ContentView: View {
    @EnvironmentObject private var deviceManager: DeviceManager
    private let logger = LoggingService.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("InfiniVision")
                    .font(.largeTitle)
                    .bold()
                
                Text("Running on \(deviceManager.getPlatformName())")
                    .font(.headline)
                
                #if os(visionOS)
                VisionOSContent()
                #elseif os(iOS)
                iOSContent()
                #elseif os(macOS)
                MacOSContent()
                #endif
            }
            .padding()
            .onAppear {
                logger.info("ContentView appeared")
            }
        }
    }
}

#if os(visionOS)
private struct VisionOSContent: View {
    var body: some View {
        Text("visionOS Specific Content")
    }
}
#endif

#if os(iOS)
private struct iOSContent: View {
    var body: some View {
        Text("iOS Specific Content")
    }
}
#endif

#if os(macOS)
private struct MacOSContent: View {
    var body: some View {
        Text("macOS Specific Content")
    }
}
#endif

#Preview {
    ContentView()
        .environmentObject(DeviceManager.shared)
} 