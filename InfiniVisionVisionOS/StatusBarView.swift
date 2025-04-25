import SwiftUI
import RealityKit

struct StatusBarView: View {
    @ObservedObject var deviceManager = DeviceManager.shared
    @State private var isExpanded = false
    
    var body: some View {
        VStack {
            if isExpanded {
                expandedView
            } else {
                collapsedView
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture {
            withAnimation(.spring()) {
                isExpanded.toggle()
            }
        }
    }
    
    private var collapsedView: some View {
        HStack {
            Image(systemName: "display")
                .font(.title2)
            Text("\(deviceManager.connectedDevices.count) Devices")
                .font(.headline)
        }
    }
    
    private var expandedView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "display")
                    .font(.title2)
                Text("Connected Devices")
                    .font(.headline)
                Spacer()
            }
            
            ForEach(deviceManager.connectedDevices) { device in
                DeviceRow(device: device)
            }
            
            if deviceManager.connectedDevices.isEmpty {
                Text("No devices connected")
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct DeviceRow: View {
    let device: DeviceManager.Device
    
    var body: some View {
        HStack {
            Image(systemName: deviceIcon)
                .font(.title3)
            VStack(alignment: .leading) {
                Text(device.name)
                    .font(.subheadline)
                Text("Battery: \(Int(device.batteryLevel * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Circle()
                .fill(device.isConnected ? Color.green : Color.gray)
                .frame(width: 8, height: 8)
        }
    }
    
    private var deviceIcon: String {
        switch device.type {
        case .mac: return "desktopcomputer"
        case .iphone: return "iphone"
        case .ipad: return "ipad"
        }
    }
} 