import SwiftUI
import AVFoundation

@main
struct InfiniVisioniOSApp: App {
    @StateObject private var deviceManager = DeviceManager.shared
    @StateObject private var audioService = AudioService.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(deviceManager)
                .environmentObject(audioService)
                .onAppear {
                    setupAudioSession()
                }
        }
    }
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.allowBluetooth, .allowBluetoothA2DP, .mixWithOthers])
            try session.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
}

struct ContentView: View {
    @EnvironmentObject private var deviceManager: DeviceManager
    @EnvironmentObject private var audioService: AudioService
    @State private var isStreaming = false
    
    var body: some View {
        NavigationView {
            List(deviceManager.availableDevices, id: \.id) { device in
                DeviceRow(device: device)
                    .onTapGesture {
                        if device.type == .visionPro {
                            if isStreaming {
                                audioService.disconnect()
                            } else {
                                audioService.connect(to: device.ipAddress, port: 5000)
                            }
                            isStreaming.toggle()
                        }
                    }
            }
            .navigationTitle("InfiniVision")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isStreaming {
                        Button(action: {
                            audioService.toggleMute()
                        }) {
                            Label(audioService.isMuted ? "Unmute" : "Mute",
                                  systemImage: audioService.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        }
                    }
                }
            }
        }
    }
} 