import Foundation

public struct StrokePoint: Sendable, Equatable {
    public let x: Double
    public let y: Double
    public let pressure: Double
    public let timestamp: TimeInterval

    public init(x: Double, y: Double, pressure: Double = 0.5, timestamp: TimeInterval = 0) {
        self.x = x; self.y = y; self.pressure = pressure; self.timestamp = timestamp
    }
}

public struct Stroke: Identifiable, Sendable, Equatable {
    public let id: String
    public let authorId: String
    public let points: [StrokePoint]
    public let colorHex: String
    public let brushSize: Double
    public let brushType: BrushType
    public let createdAt: Date

    public init(id: String = UUID().uuidString, authorId: String, points: [StrokePoint],
                colorHex: String, brushSize: Double, brushType: BrushType, createdAt: Date = .now) {
        self.id = id; self.authorId = authorId; self.points = points
        self.colorHex = colorHex; self.brushSize = brushSize
        self.brushType = brushType; self.createdAt = createdAt
    }
}

public enum BrushType: String, Sendable, CaseIterable {
    case pen, brush, chalk, highlighter, eraser
}

public struct Drawing: Identifiable, Sendable, Equatable {
    public let id: String
    public let coupleId: String
    public let authorId: String
    public var strokes: [Stroke]
    public let previewURL: URL?
    public let fullURL: URL?
    public let createdAt: Date
    public let finishedAt: Date?
}

public enum CanvasError: Error, Sendable {
    case drawingNotFound
    case uploadFailed(Error)
    case networkError(Error)
}

public protocol CanvasRepository: Sendable {
    func createDrawing(coupleId: String) async throws -> Drawing
    func appendStrokes(_ strokes: [Stroke], drawingId: String) async throws
    func finalizeDrawing(_ drawingId: String) async throws -> Drawing
    func fetchDrawings(coupleId: String, page: Int) async throws -> [Drawing]
    func fetchDrawing(_ id: String) async throws -> Drawing
}
