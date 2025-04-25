import SwiftUI

class InputService: ObservableObject {
    @Published var isEnabled = false
    
    func enableInput() {
        // Implementation for enabling input
        isEnabled = true
    }
    
    func disableInput() {
        // Implementation for disabling input
        isEnabled = false
    }
} 