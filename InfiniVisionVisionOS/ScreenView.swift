import SwiftUI
import RealityKit
import AVFoundation

struct ScreenView: View {
    let device: DeviceManager.Device
    @StateObject private var screenCaptureService = ScreenCaptureService.shared
    @StateObject private var inputService = InputService.shared
    @State private var image: UIImage?
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var isDragging = false
    
    var body: some View {
        GeometryReader { geometry in
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale)
                    .offset(offset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if !isDragging {
                                    isDragging = true
                                }
                                offset = CGSize(
                                    width: offset.width + value.translation.width,
                                    height: offset.height + value.translation.height
                                )
                            }
                            .onEnded { value in
                                isDragging = false
                            }
                    )
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = value
                            }
                    )
                    .gesture(
                        TapGesture(count: 2)
                            .onEnded {
                                scale = 1.0
                                offset = .zero
                            }
                    )
                    .onTapGesture { location in
                        let normalizedLocation = CGPoint(
                            x: location.x / geometry.size.width,
                            y: location.y / geometry.size.height
                        )
                        let event = MouseEvent(
                            type: .down,
                            position: normalizedLocation,
                            button: .left,
                            delta: nil
                        )
                        inputService.sendMouseEvent(event)
                    }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            setupScreenCapture()
        }
        .onDisappear {
            screenCaptureService.stopCapture()
        }
    }
    
    private func setupScreenCapture() {
        Task {
            do {
                try await screenCaptureService.startCapture(for: device)
                setupImageReceiver()
            } catch {
                print("Failed to start screen capture: \(error)")
            }
        }
    }
    
    private func setupImageReceiver() {
        screenCaptureService.connection?.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.image = image
                }
            }
            
            if !isComplete && error == nil {
                self?.setupImageReceiver()
            }
        }
    }
}

struct ScreenWindow: View {
    let device: DeviceManager.Device
    @State private var isFocused = false
    
    var body: some View {
        VStack {
            HStack {
                Text(device.name)
                    .font(.headline)
                Spacer()
                Button(action: {
                    DeviceManager.shared.disconnect(from: device)
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            
            ScreenView(device: device)
        }
        .frame(width: 800, height: 600)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 10)
        .onHover { hovering in
            isFocused = hovering
        }
    }
} 