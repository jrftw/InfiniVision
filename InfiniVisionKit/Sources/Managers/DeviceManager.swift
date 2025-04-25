import Foundation
import AVFoundation
import Combine

@available(iOS 17.0, macOS 14.0, visionOS 1.0, *)
public class DeviceManager: ObservableObject {
    @Published public private(set) var discoveredDevices: [AVCaptureDevice] = []
    @Published public private(set) var isScanning = false
    
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
        setupNotifications()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.publisher(for: .AVCaptureDeviceWasConnected)
            .sink { [weak self] _ in
                self?.refreshDevices()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .AVCaptureDeviceWasDisconnected)
            .sink { [weak self] _ in
                self?.refreshDevices()
            }
            .store(in: &cancellables)
    }
    
    public func startScanning() {
        guard !isScanning else { return }
        isScanning = true
        refreshDevices()
        LoggingService.shared.info("Device scanning started")
    }
    
    public func stopScanning() {
        guard isScanning else { return }
        isScanning = false
        LoggingService.shared.info("Device scanning stopped")
    }
    
    private func refreshDevices() {
        let devices = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.externalUnknown, .builtInWideAngleCamera],
            mediaType: .video,
            position: .unspecified
        ).devices
        
        DispatchQueue.main.async {
            self.discoveredDevices = devices
            LoggingService.shared.info("Found \(devices.count) devices")
        }
    }
} 