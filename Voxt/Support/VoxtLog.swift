import Foundation

enum VoxtLog {
    static var verboseEnabled = false

    static func info(_ message: @autoclosure () -> String, verbose: Bool = false) {
        log(message(), verbose: verbose)
    }

    static func warning(_ message: @autoclosure () -> String) {
        log(message())
    }

    static func error(_ message: @autoclosure () -> String) {
        log(message())
    }

    private static func log(_ message: String, verbose: Bool = false) {
        guard !verbose || verboseEnabled else { return }
        print("[Voxt] \(message)")
    }
}
