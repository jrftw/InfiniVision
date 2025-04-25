import Foundation
import Network
import Combine
import SwiftUI

class DeviceManager: ObservableObject {
    static let shared = DeviceManager()
    
    @Published var connectedDevices: [Device] = []
    @Published var isScanning = false
    @Published var errorMessage: String?
    
    private var browser: NWBrowser?
    private var listener: NWListener?
    private var connections: [UUID: NWConnection] = [:]
    private var deviceInfo: [UUID: DeviceInfo] = [:]
    
    struct Device: Identifiable, Hashable {
        let id: UUID
        let name: String
        let type: DeviceType
        let batteryLevel: Double
        var isConnected: Bool
        var endpoint: NWEndpoint?
        
        enum DeviceType: String, Codable {
            case mac
            case iphone
            case ipad
        }
    }
    
    private struct DeviceInfo: Codable {
        let name: String
        let type: Device.DeviceType
        let batteryLevel: Double
    }
    
    private init() {
        setupNetworkServices()
    }
    
    private func setupNetworkServices() {
        setupBrowser()
        setupListener()
    }
    
    private func setupBrowser() {
        let parameters = NWParameters()
        parameters.includePeerToPeer = true
        
        browser = NWBrowser(for: .bonjour(type: "_infinivision._tcp", domain: nil), using: parameters)
        browser?.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                self?.isScanning = true
            case .failed(let error):
                print("Browser failed with error: \(error)")
                self?.isScanning = false
            default:
                break
            }
        }
        
        browser?.browseResultsChangedHandler = { [weak self] results, _ in
            self?.updateDevices(from: results)
        }
        
        browser?.start(queue: .main)
    }
    
    private func setupListener() {
        let parameters = NWParameters()
        parameters.includePeerToPeer = true
        
        do {
            listener = try NWListener(using: parameters)
            listener?.service = NWListener.Service(name: UIDevice.current.name, type: "_infinivision._tcp")
            
            listener?.stateUpdateHandler = { [weak self] state in
                switch state {
                case .ready:
                    print("Listener ready")
                case .failed(let error):
                    print("Listener failed: \(error)")
                default:
                    break
                }
            }
            
            listener?.newConnectionHandler = { [weak self] connection in
                self?.handleNewConnection(connection)
            }
            
            listener?.start(queue: .main)
        } catch {
            print("Failed to create listener: \(error)")
        }
    }
    
    private func updateDevices(from results: Set<NWBrowser.Result>) {
        let newDevices = results.map { result -> Device in
            let endpoint = result.endpoint
            let name = endpoint.debugDescription
            let type: Device.DeviceType = .mac // This would be determined from the device info
            return Device(id: UUID(), name: name, type: type, batteryLevel: 1.0, isConnected: false, endpoint: endpoint)
        }
        
        DispatchQueue.main.async {
            self.connectedDevices = newDevices
        }
    }
    
    private func handleNewConnection(_ connection: NWConnection) {
        connection.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                self?.receiveDeviceInfo(from: connection)
            case .failed(let error):
                print("Connection failed: \(error)")
                self?.removeConnection(connection)
            default:
                break
            }
        }
        
        connection.start(queue: .main)
    }
    
    private func receiveDeviceInfo(from connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            if let data = data, let deviceInfo = try? JSONDecoder().decode(DeviceInfo.self, from: data) {
                let device = Device(id: UUID(),
                                  name: deviceInfo.name,
                                  type: deviceInfo.type,
                                  batteryLevel: deviceInfo.batteryLevel,
                                  isConnected: true,
                                  endpoint: connection.endpoint)
                
                DispatchQueue.main.async {
                    self?.connectedDevices.append(device)
                }
                
                self?.connections[device.id] = connection
            }
            
            if isComplete || error != nil {
                self?.removeConnection(connection)
            }
        }
    }
    
    func connect(to device: Device) {
        guard let endpoint = device.endpoint else { return }
        
        let connection = NWConnection(to: endpoint, using: .tcp)
        connection.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                self?.sendDeviceInfo(connection)
                DispatchQueue.main.async {
                    if let index = self?.connectedDevices.firstIndex(where: { $0.id == device.id }) {
                        self?.connectedDevices[index].isConnected = true
                    }
                }
            case .failed(let error):
                print("Connection failed: \(error)")
                self?.removeConnection(connection)
            default:
                break
            }
        }
        
        connection.start(queue: .main)
        connections[device.id] = connection
    }
    
    private func sendDeviceInfo(_ connection: NWConnection) {
        let deviceInfo = DeviceInfo(name: UIDevice.current.name,
                                  type: .mac, // This should be determined based on the current device
                                  batteryLevel: UIDevice.current.batteryLevel)
        
        if let data = try? JSONEncoder().encode(deviceInfo) {
            connection.send(content: data, completion: .contentProcessed { error in
                if let error = error {
                    print("Error sending device info: \(error)")
                }
            })
        }
    }
    
    func disconnect(from device: Device) {
        if let connection = connections[device.id] {
            connection.cancel()
            removeConnection(connection)
        }
        
        if let index = connectedDevices.firstIndex(where: { $0.id == device.id }) {
            connectedDevices[index].isConnected = false
        }
    }
    
    private func removeConnection(_ connection: NWConnection) {
        if let (id, _) = connections.first(where: { $0.value === connection }) {
            connections.removeValue(forKey: id)
            if let index = connectedDevices.firstIndex(where: { $0.id == id }) {
                connectedDevices[index].isConnected = false
            }
        }
    }
} 