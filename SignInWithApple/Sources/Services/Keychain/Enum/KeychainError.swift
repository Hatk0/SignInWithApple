import Foundation

enum KeychainError: Error {
    case saveFailed(status: OSStatus)
    case loadFailed(status: OSStatus)
    case itemNotFound
    case deleteFailed(status: OSStatus)
}
