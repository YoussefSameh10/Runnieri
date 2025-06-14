import Foundation
import SwiftData

@ModelActor
actor SwiftDataWrapper: DataSource {
    private let schema = Schema([ActivityDataModel.self])
    private static var shared: DataSource?
    
    private init() throws {
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: ModelContext(modelContainer))
    }
    
    static func getInstance() -> DataSource {
        guard let shared else {
            shared = try? SwiftDataWrapper()
            return shared ?? NullDataSource()
        }
        return shared
    }
    
    func save<Model: DataModel>(_ item: Model) async throws {
        modelContext.insert(item)
        try modelContext.save()
    }
    
    func fetch<Model: DataModel>(
        _: Model.Type,
        predicate: Predicate<Model>?,
        sortBy: [SortDescriptor<Model>]
    ) async throws -> [Model] {
        let descriptor = FetchDescriptor<Model>(predicate: predicate, sortBy: sortBy)
        return try modelContext.fetch(descriptor)
    }
    
    func delete<Model: DataModel>(_ item: Model) async throws {
        modelContext.delete(item)
        try modelContext.save()
    }
    
    func update<Model: DataModel>(_ item: Model) async throws {
        try modelContext.save()
    }
}
