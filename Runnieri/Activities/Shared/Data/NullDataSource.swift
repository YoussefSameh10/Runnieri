//
//  NullDataSource.swift
//  Runnieri
//
//  Created by Youssef Ghattas on 01/06/2025.
//

import Foundation

struct NullDataSource: DataSource {
    func save<Model>(_ item: Model) async throws where Model : DataModel { }
    
    func fetch<Model>(_: Model.Type, predicate: Predicate<Model>?, sortBy: [SortDescriptor<Model>]) async throws -> [Model] where Model : DataModel {
        []
    }
    
    func delete<Model>(_ item: Model) async throws where Model : DataModel { }
    
    func update<Model>(_ item: Model) async throws where Model : DataModel { }
}
