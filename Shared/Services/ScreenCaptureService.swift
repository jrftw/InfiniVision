import SwiftUI

class ScreenCaptureService: ObservableObject {
    @Published var isCapturing = false
    @Published var currentFrame: CGImage?
    
    func startCapture() {
        // Implementation for screen capture
        isCapturing = true
    }
    
    func stopCapture() {
        // Implementation for stopping capture
        isCapturing = false
        currentFrame = nil
    }
} 