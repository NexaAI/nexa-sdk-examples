
import OSLog
import Foundation

struct Log {

    private init() { }
    
    static let logger = Logger(subsystem: "com.nexa.ai.nexastudio", category: "log")

    static func error(_ items: Any...) {
        var info = ""
        for item in items {
            info += "\(item)"
        }
        logger.error("\(info)")
    }

    static func warn(_ items: Any...) {
        var info = ""
        for item in items {
            info += "\(item)"
        }
        logger.warning("\(info)")
    }

    static func info(_ items: Any...) {
        var info = ""
        for item in items {
            info += "\(item)"
        }
        logger.info("\(info)")
    }

}
