import Foundation
import os.log

public struct FHBLogger {
    private let logger: Logger

    public init(subsystem: String = "com.fanhb.app", category: String) {
        self.logger = Logger(subsystem: subsystem, category: category)
    }

    public func debug(_ message: String) { logger.debug("\(message)") }
    public func info(_ message: String) { logger.info("\(message)") }
    public func warning(_ message: String) { logger.warning("\(message)") }
    public func error(_ message: String) { logger.error("\(message)") }
    public func fault(_ message: String) { logger.fault("\(message)") }
}
