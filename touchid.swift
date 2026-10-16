// Touch ID check for the tripwire. Exits 0 on a fingerprint match, non-zero otherwise.
// Build (from the config dir): mkdir -p bin && swiftc -O touchid.swift -o bin/touchid
import Foundation
import LocalAuthentication

let context = LAContext()
context.localizedFallbackTitle = "" // fingerprint only, no password fallback

var error: NSError?
guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
  FileHandle.standardError.write("Touch ID unavailable: \(error?.localizedDescription ?? "?")\n".data(using: .utf8)!)
  exit(2)
}

let reason = CommandLine.arguments.dropFirst().first ?? "authenticate"
context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { ok, _ in
  exit(ok ? 0 : 1)
}
dispatchMain()
