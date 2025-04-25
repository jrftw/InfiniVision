import Foundation
import OSLog

public enum LogLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
    case critical = "CRITICAL"
    
    var osLogType: OSLogType {
        switch self {
        case .debug: return .debug
        case .info: return .info
        case .warning: return .default
        case .error: return .error
        case .critical: return .fault
        }
    }
}

public class LoggingService {
    public static let shared = LoggingService()
    
    private let logger: Logger
    private let dateFormatter: DateFormatter
    private let subsystem = Bundle.main.bundleIdentifier ?? "com.infinivision"
    
    private init() {
        logger = Logger(subsystem: subsystem, category: "InfiniVision")
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        
        log("LoggingService initialized", level: .info)
    }
    
    public func log(_ message: String,
                   level: LogLevel = .info,
                   file: String = #file,
                   function: String = #function,
                   line: Int = #line) {
        let timestamp = dateFormatter.string(from: Date())
        let filename = (file as NSString).lastPathComponent
        let logMessage = "[\(timestamp)] [\(level.rawValue)] [\(filename):\(line)] \(function) - \(message)"
        
        // Log to system log
        logger.log(level: level.osLogType, "\(logMessage)")
        
        #if DEBUG
        // In debug mode, also print to console
        print(logMessage)
        #endif
    }
    
    public func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, file: file, function: function, line: line)
    }
    
    public func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, file: file, function: function, line: line)
    }
    
    public func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, file: file, function: function, line: line)
    }
    
    public func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .error, file: file, function: function, line: line)
    }
    
    public func critical(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .critical, file: file, function: function, line: line)
    }
} 