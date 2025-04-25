import Foundation
import Network
import CoreGraphics

class InputService: ObservableObject {
    static let shared = InputService()
    
    private var connection: NWConnection?
    private var isConnected = false
    
    private init() {}
    
    func connect(to endpoint: NWEndpoint) {
        let connection = NWConnection(to: endpoint, using: .tcp)
        self.connection = connection
        
        connection.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                self?.isConnected = true
            case .failed(let error):
                print("Input connection failed: \(error)")
                self?.isConnected = false
            default:
                break
            }
        }
        
        connection.start(queue: .main)
    }
    
    func sendMouseEvent(_ event: MouseEvent) {
        guard isConnected else { return }
        
        let data = try? JSONEncoder().encode(event)
        connection?.send(content: data, completion: .contentProcessed { error in
            if let error = error {
                print("Error sending mouse event: \(error)")
            }
        })
    }
    
    func sendKeyboardEvent(_ event: KeyboardEvent) {
        guard isConnected else { return }
        
        let data = try? JSONEncoder().encode(event)
        connection?.send(content: data, completion: .contentProcessed { error in
            if let error = error {
                print("Error sending keyboard event: \(error)")
            }
        })
    }
    
    func sendTouchEvent(_ event: TouchEvent) {
        guard isConnected else { return }
        
        let data = try? JSONEncoder().encode(event)
        connection?.send(content: data, completion: .contentProcessed { error in
            if let error = error {
                print("Error sending touch event: \(error)")
            }
        })
    }
}

struct MouseEvent: Codable {
    let type: EventType
    let position: CGPoint
    let button: Button
    let delta: CGPoint?
    
    enum EventType: String, Codable {
        case move
        case down
        case up
        case drag
        case scroll
    }
    
    enum Button: String, Codable {
        case left
        case right
        case middle
    }
}

struct KeyboardEvent: Codable {
    let type: EventType
    let key: String
    let modifiers: [Modifier]
    
    enum EventType: String, Codable {
        case down
        case up
    }
    
    enum Modifier: String, Codable {
        case shift
        case control
        case option
        case command
    }
}

struct TouchEvent: Codable {
    let type: EventType
    let position: CGPoint
    let force: CGFloat
    
    enum EventType: String, Codable {
        case began
        case moved
        case ended
        case cancelled
    }
} 