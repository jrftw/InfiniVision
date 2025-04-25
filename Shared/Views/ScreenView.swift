import SwiftUI

struct ScreenView: View {
    @EnvironmentObject var deviceManager: DeviceManager
    @EnvironmentObject var screenCaptureService: ScreenCaptureService
    
    var body: some View {
        VStack {
            if deviceManager.isConnected {
                if screenCaptureService.isCapturing {
                    Text("Capturing Screen")
                } else {
                    Button("Start Capture") {
                        screenCaptureService.startCapture()
                    }
                }
            } else {
                Button("Connect Device") {
                    deviceManager.connect()
                }
            }
        }
        .padding()
    }
} 