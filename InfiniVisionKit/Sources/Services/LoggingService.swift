import Foundation
import os.log

@available(iOS 17.0, macOS 14.0, visionOS 1.0, *)
public class LoggingService {
    public static let shared = LoggingService()
    
    private let logger: Logger
    private let subsystem: String
    
    private init() {
        subsystem = "com.infinivision"
        logger = Logger(subsystem: subsystem, category: "app")
    }
    
    public func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        logger.info("\(message) [\(file):\(line)]")
    }
    
    public func error(_ message: String, error: Error? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        if let error = error {
            logger.error("\(message) - Error: \(error.localizedDescription) [\(file):\(line)]")
        } else {
            logger.error("\(message) [\(file):\(line)]")
        }
    }
    
    public func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        logger.warning("\(message) [\(file):\(line)]")
    }
    
    public func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        logger.debug("\(message) [\(file):\(line)]")
        #endif
    }
    
    #if os(iOS)
    public func logDeviceInfo() {
        let device = UIDevice.current
        info("Device: \(device.model), iOS \(device.systemVersion)")
    }
    #elseif os(macOS)
    public func logDeviceInfo() {
        let processInfo = ProcessInfo.processInfo
        info("macOS \(processInfo.operatingSystemVersionString)")
    }
    #elseif os(visionOS)
    public func logDeviceInfo() {
        info("visionOS device")
    }
    #endif
} 