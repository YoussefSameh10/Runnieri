//
//  HealthDataSource.swift
//  Runnieri
//
//  Created by Youssef Ghattas on 06/06/2025.
//

import Foundation

protocol HealthDataSource {
    var caloriesStream: AsyncStream<Double> { get }
    func startLiveCalorieTracking() async throws
    func stopLiveCalorieTracking() async throws
    func fetchActiveEnergyBurned(from startDate: Date, to endDate: Date) async throws -> Double
}
