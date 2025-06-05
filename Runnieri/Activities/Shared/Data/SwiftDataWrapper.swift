import Foundation
import SwiftData

actor SwiftDataWrapper: DataSource {
    private let modelContainer: ModelContainer
    private let context: ModelContext
    private let schema = Schema([ActivityDataModel.self])
    private static var shared: DataSource?
    
    private init() throws {
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        context = ModelContext(modelContainer)
    }
    
    static func getInstance() -> DataSource {
        guard let shared else {
            shared = try? SwiftDataWrapper()
            return shared ?? NullDataSource()
        }
        return shared
    }
    
    func save<Model: DataModel>(_ item: Model) async throws {
        context.insert(item)
        try context.save()
    }
    
    func fetch<Model: DataModel>(_: Model.Type, predicate: Predicate<Model>?, sortBy: [SortDescriptor<Model>]) async throws -> [Model] {
        let descriptor = FetchDescriptor<Model>(predicate: predicate, sortBy: sortBy)
        return try context.fetch(descriptor)
    }
    
    func delete<Model: DataModel>(_ item: Model) async throws {
        context.delete(item)
        try context.save()
    }
    
    func update<Model: DataModel>(_ item: Model) async throws {
        try context.save()
    }
}
