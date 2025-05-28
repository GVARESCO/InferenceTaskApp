//
//  Trial.swift
//  InferenceTaskApp
//
//  Created by Giorgio Varesco on 2025-05-25.
//

import Foundation

struct Trial: Identifiable, Codable {
    let id = UUID()
    let trialNumber: Int
    let responseTime: Double
    let isCorrect: Bool
    let combination: String
}
