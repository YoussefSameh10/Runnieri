import Foundation

protocol DataSource {
    func save<Model: DataModel>(_ item: Model) async throws
    func fetch<Model: DataModel>(_: Model.Type, predicate: Predicate<Model>?, sortBy: [SortDescriptor<Model>]) async throws -> [Model]
    func delete<Model: DataModel>(_ item: Model) async throws
    func update<Model: DataModel>(_ item: Model) async throws
}
