//
//  HealthDataSource.swift
//  Runnieri
//
//  Created by Youssef Ghattas on 06/06/2025.
//

import Combine
import Foundation

protocol HealthDataSource {
    var caloriesPublisher: AnyPublisher<Double, Never> { get }
    func startLiveCalorieTracking() async throws
    func stopLiveCalorieTracking() async
    func fetchActiveEnergyBurned(from startDate: Date, to endDate: Date) async throws -> Double
}
