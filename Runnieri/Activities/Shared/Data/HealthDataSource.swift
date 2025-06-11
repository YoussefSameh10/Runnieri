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
    func stopLiveCalorieTracking() async throws
    func fetchActiveEnergyBurned(from startTime: TimeInterval, to endTime: TimeInterval) async throws -> Double
}
