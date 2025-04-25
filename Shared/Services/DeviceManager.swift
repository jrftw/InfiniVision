import SwiftUI

class DeviceManager: ObservableObject {
    @Published var isConnected = false
    @Published var selectedDevice: String?
    
    func connect() {
        // Implementation for device connection
        isConnected = true
    }
    
    func disconnect() {
        // Implementation for device disconnection
        isConnected = false
        selectedDevice = nil
    }
} 