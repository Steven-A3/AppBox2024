//
//  Logger.swift
//  AppBox3
//
//  Created by BYEONG KWON KWAK on 12/14/24.
//  Copyright © 2024 ALLABOUTAPPS. All rights reserved.
//


import Foundation

/// A versatile logging utility for Swift
public class Logger {
    
    /// Log levels
    public enum LogLevel: String {
        case debug = "DEBUG"
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"
    }
    
    /// Shared instance for global access
    public static let shared = Logger()
    
    /// Date formatter for timestamps
    private let dateFormatter: DateFormatter
    
    /// Enable/disable logging
    public var isLoggingEnabled: Bool = true
    
    /// Initialize the logger
    private init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    }
    
    /// Log a message with a specific level
    /// - Parameters:
    ///   - level: The log level
    ///   - message: The message to log
    ///   - file: The file name (default: #file)
    ///   - function: The function name (default: #function)
    ///   - line: The line number (default: #line)
    public func log(_ level: LogLevel, _ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        guard isLoggingEnabled else { return }
        
        let timestamp = dateFormatter.string(from: Date())
        let fileName = (file as NSString).lastPathComponent
        let logMessage = "[\(timestamp)] [\(level.rawValue)] [\(fileName):\(line)] \(function) - \(message)"
        
        print(logMessage)
    }
    
    /// Convenience methods for each log level
    public func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(.debug, message, file: file, function: function, line: line)
    }
    
    public func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(.info, message, file: file, function: function, line: line)
    }
    
    public func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(.warning, message, file: file, function: function, line: line)
    }
    
    public func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(.error, message, file: file, function: function, line: line)
    }
}
