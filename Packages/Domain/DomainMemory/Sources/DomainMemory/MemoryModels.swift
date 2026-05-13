import Foundation

public struct Memory: Identifiable, Sendable, Equatable {
    public let id: String
    public let coupleId: String
    public let drawingId: String
    public let thumbnailURL: URL?
    public let note: String?
    public let tags: [String]
    public let createdAt: Date
    public let authorId: String
}

public struct MemoryAlbum: Identifiable, Sendable, Equatable {
    public let id: String
    public let title: String
    public let memories: [Memory]
    public let coverURL: URL?
}

public protocol MemoryRepository: Sendable {
    func fetchMemories(coupleId: String, page: Int) async throws -> [Memory]
    func fetchMemory(_ id: String) async throws -> Memory
    func addNote(_ note: String, to memoryId: String) async throws -> Memory
    func addTags(_ tags: [String], to memoryId: String) async throws -> Memory
    func deleteMemory(_ id: String) async throws
}
