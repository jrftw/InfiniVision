import SwiftUI
import RealityKit

@main
struct InfiniVisionApp: App {
    @StateObject private var deviceManager = DeviceManager.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @StateObject private var audioService = AudioService.shared
    @State private var selectedDevice: Device?
    @State private var isImmersed = false
    @State private var showSubscriptionAlert = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(deviceManager)
                .environmentObject(subscriptionManager)
                .environmentObject(audioService)
                .onAppear {
                    checkSubscription()
                }
                .alert("Subscription Required", isPresented: $showSubscriptionAlert) {
                    Button("Subscribe", action: {
                        subscriptionManager.purchaseSubscription()
                    })
                    .buttonStyle(ModernButtonStyle())
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Your trial has expired. Please subscribe to continue using InfiniVision.")
                        .font(DesignSystem.Fonts.body)
                }
        }
        .windowStyle(.plain)
        .defaultSize(width: 0.5, height: 0.5)
        
        ImmersiveSpace(id: "ImmersiveSpace") {
            if let device = selectedDevice {
                ImmersiveView(device: device)
                    .environmentObject(audioService)
            }
        }
        .immersionStyle(selection: .constant(.full), in: .full)
    }
    
    private func checkSubscription() {
        if !subscriptionManager.isSubscribed && subscriptionManager.trialExpired {
            showSubscriptionAlert = true
        }
    }
}

struct ContentView: View {
    @EnvironmentObject private var deviceManager: DeviceManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @EnvironmentObject private var audioService: AudioService
    @State private var selectedDevice: Device?
    @State private var isImmersed = false
    
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(deviceManager.availableDevices, id: \.id) { device in
                    ModernListRow {
                        DeviceRow(device: device)
                            .onTapGesture {
                                selectedDevice = device
                                if device.type == .mac {
                                    audioService.connect(to: device.ipAddress, port: 5000)
                                }
                            }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Devices")
            .font(DesignSystem.Fonts.title)
        } detail: {
            if let device = selectedDevice {
                VStack(spacing: DesignSystem.Spacing.large) {
                    ModernCard {
                        ScreenView(device: device)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    
                    HStack(spacing: DesignSystem.Spacing.medium) {
                        Button(action: {
                            isImmersed.toggle()
                            if isImmersed {
                                openImmersiveSpace()
                            } else {
                                dismissImmersiveSpace()
                            }
                        }) {
                            Label(isImmersed ? "Exit Immersion" : "Enter Immersion",
                                  systemImage: isImmersed ? "rectangle.portrait.and.arrow.right" : "rectangle.portrait.and.arrow.forward")
                        }
                        .buttonStyle(ModernButtonStyle())
                        
                        Spacer()
                        
                        if device.type == .mac {
                            Button(action: {
                                audioService.toggleMute()
                            }) {
                                Label(audioService.isMuted ? "Unmute" : "Mute",
                                      systemImage: audioService.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                            }
                            .buttonStyle(ModernButtonStyle(isPrimary: false))
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.medium)
                }
                .padding(DesignSystem.Spacing.medium)
            } else {
                VStack(spacing: DesignSystem.Spacing.medium) {
                    Image(systemName: "display.2")
                        .font(.system(size: 60))
                        .foregroundColor(DesignSystem.Colors.secondary)
                    Text("Select a device to begin")
                        .font(DesignSystem.Fonts.headline)
                        .foregroundColor(DesignSystem.Colors.text)
                }
            }
        }
    }
    
    private func openImmersiveSpace() {
        Task {
            await openImmersiveSpace(id: "ImmersiveSpace")
        }
    }
    
    private func dismissImmersiveSpace() {
        Task {
            await dismissImmersiveSpace()
        }
    }
}

struct ImmersiveView: View {
    let device: Device
    @EnvironmentObject private var audioService: AudioService
    
    var body: some View {
        RealityView { content in
            let box = MeshResource.generateBox(size: 0.1)
            let material = SimpleMaterial(color: .blue, isMetallic: true)
            let entity = ModelEntity(mesh: box, materials: [material])
            content.add(entity)
        }
        .overlay(alignment: .bottom) {
            if device.type == .mac {
                Button(action: {
                    audioService.toggleMute()
                }) {
                    Label(audioService.isMuted ? "Unmute" : "Mute",
                          systemImage: audioService.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                }
                .buttonStyle(ModernButtonStyle())
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(DesignSystem.CornerRadius.medium)
            }
        }
    }
}

struct DeviceRow: View {
    let device: Device
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.medium) {
            Image(systemName: deviceIcon)
                .font(.system(size: 24))
                .foregroundColor(DesignSystem.Colors.primary)
                .frame(width: 40, height: 40)
                .background(DesignSystem.Colors.primary.opacity(0.1))
                .cornerRadius(DesignSystem.CornerRadius.small)
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                Text(device.name)
                    .font(DesignSystem.Fonts.headline)
                    .foregroundColor(DesignSystem.Colors.text)
                Text(device.type.rawValue)
                    .font(DesignSystem.Fonts.caption)
                    .foregroundColor(DesignSystem.Colors.secondary)
            }
            
            Spacer()
            
            Circle()
                .fill(device.isConnected ? Color.green : Color.gray)
                .frame(width: 12, height: 12)
        }
    }
    
    private var deviceIcon: String {
        switch device.type {
        case .mac: return "desktopcomputer"
        case .iphone: return "iphone"
        case .ipad: return "ipad"
        case .visionPro: return "visionpro"
        }
    }
}

struct DeviceControlView: View {
    let device: DeviceManager.Device
    @State private var showScreen = false
    
    var body: some View {
        VStack {
            if showScreen {
                ScreenWindow(device: device)
            } else {
                Button("Show Screen") {
                    showScreen = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct MacControlView: View {
    var body: some View {
        // Add Mac-specific controls
        Text("Mac Controls")
    }
}

struct iOSControlView: View {
    var body: some View {
        // Add iOS/iPadOS-specific controls
        Text("iOS Controls")
    }
} 
} 