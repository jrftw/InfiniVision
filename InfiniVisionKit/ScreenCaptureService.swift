import Foundation
import AVFoundation
import ScreenCaptureKit
import Network

class ScreenCaptureService: ObservableObject {
    static let shared = ScreenCaptureService()
    
    private var captureSession: AVCaptureSession?
    private var screenRecorder: SCStream?
    private var connection: NWConnection?
    private var isStreaming = false
    
    private init() {}
    
    func startCapture(for device: DeviceManager.Device) async throws {
        #if os(macOS)
        try await startMacCapture()
        #elseif os(iOS)
        try await startiOSCapture()
        #endif
    }
    
    func stopCapture() {
        screenRecorder?.stopCapture()
        captureSession?.stopRunning()
        isStreaming = false
    }
    
    #if os(macOS)
    private func startMacCapture() async throws {
        let availableContent = try await SCShareableContent.current
        guard let mainDisplay = availableContent.displays.first else {
            throw ScreenCaptureError.noDisplayAvailable
        }
        
        let filter = SCContentFilter(display: mainDisplay,
                                   excludingApplications: [],
                                   exceptingWindows: [])
        
        let configuration = SCStreamConfiguration()
        configuration.width = mainDisplay.width
        configuration.height = mainDisplay.height
        configuration.minimumFrameInterval = CMTime(value: 1, timescale: 60)
        configuration.queueDepth = 6
        
        screenRecorder = SCStream(filter: filter, configuration: configuration, delegate: self)
        try await screenRecorder?.startCapture()
        isStreaming = true
    }
    #endif
    
    #if os(iOS)
    private func startiOSCapture() async throws {
        let captureSession = AVCaptureSession()
        self.captureSession = captureSession
        
        guard let screen = AVCaptureScreenInput(displayID: CGMainDisplayID()) else {
            throw ScreenCaptureError.noDisplayAvailable
        }
        
        if captureSession.canAddInput(screen) {
            captureSession.addInput(screen)
        }
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: .userInteractive))
        
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
        
        captureSession.startRunning()
        isStreaming = true
    }
    #endif
    
    func connect(to endpoint: NWEndpoint) {
        let connection = NWConnection(to: endpoint, using: .tcp)
        self.connection = connection
        
        connection.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                print("Connection ready")
            case .failed(let error):
                print("Connection failed: \(error)")
                self?.stopCapture()
            default:
                break
            }
        }
        
        connection.start(queue: .main)
    }
}

extension ScreenCaptureService: SCStreamDelegate {
    func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
        guard type == .screen else { return }
        
        // Convert sample buffer to data and send over network
        if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            let ciImage = CIImage(cvImageBuffer: imageBuffer)
            let context = CIContext()
            if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                let image = UIImage(cgImage: cgImage)
                if let data = image.jpegData(compressionQuality: 0.8) {
                    connection?.send(content: data, completion: .contentProcessed { error in
                        if let error = error {
                            print("Error sending frame: \(error)")
                        }
                    })
                }
            }
        }
    }
}

extension ScreenCaptureService: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Handle iOS screen capture
        if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            let ciImage = CIImage(cvImageBuffer: imageBuffer)
            let context = CIContext()
            if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                let image = UIImage(cgImage: cgImage)
                if let data = image.jpegData(compressionQuality: 0.8) {
                    connection?.send(content: data, completion: .contentProcessed { error in
                        if let error = error {
                            print("Error sending frame: \(error)")
                        }
                    })
                }
            }
        }
    }
}

enum ScreenCaptureError: Error {
    case noDisplayAvailable
    case captureFailed
    case connectionFailed
} 