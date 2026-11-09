import Foundation

public protocol MedicalRepository: Sendable {
    func save(data: MedicalData) async throws
    func load() async throws -> MedicalData?
    func clear() async throws
}

public final class LocalMedicalRepository: MedicalRepository {
    private let fileName = "medical_data.json"

    private var fileURL: URL {
        #if SKIP
        let dir = ProcessInfo.processInfo.androidContext.getFilesDir().getAbsolutePath()
        return URL(fileURLWithPath: "\(dir)/\(fileName)")
        #else
        return URL.documentsDirectory.appendingPathComponent(fileName)
        #endif
    }

    public init() {}

    public func save(data: MedicalData) async throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try encoder.encode(data)

        // Ensure parent directory exists
        let parentDir = fileURL.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: parentDir.path) {
            try FileManager.default.createDirectory(at: parentDir, withIntermediateDirectories: true)
        }

        try jsonData.write(to: fileURL)
    }

    public func load() async throws -> MedicalData? {
        // Check if file exists
        let path = fileURL.path
        guard FileManager.default.fileExists(atPath: path) else {
            return nil
        }

        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(MedicalData.self, from: data)
    }

    public func clear() async throws {
        let path = fileURL.path
        if FileManager.default.fileExists(atPath: path) {
            try FileManager.default.removeItem(at: fileURL)
        }
    }
}
