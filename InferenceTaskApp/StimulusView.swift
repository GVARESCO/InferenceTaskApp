//
//  StimulusView.swift
//  InferenceTaskApp
//
//  Created by Giorgio Varesco on 2025-05-25.
//

import SwiftUI

struct StimulusView: View {
    // The three numbers to display, for example: [1, 2, 3]
    let numbers: [Int]
    
    // Closure to handle answer selection
    let onAnswer: (Int) -> Void
    
    // Random colors and font sizes per number
    @State private var colors: [Color] = []
    @State private var fontSizes: [CGFloat] = []
    
    // Possible colors and font sizes
    private let possibleColors: [Color] = [.red, .green, .blue, .orange, .purple, .pink, .yellow]
    private let possibleFontSizes: [CGFloat] = [20, 40, 60, 80]
    
    var body: some View {
        HStack(spacing: 40) {
            ForEach(numbers.indices, id: \.self) { index in
                Button(action: {
                    onAnswer(numbers[index])
                }) {
                    Text("\(numbers[index])")
                        .font(.system(size: fontSizes.indices.contains(index) ? fontSizes[index] : 40, weight: .bold))
                        .foregroundColor(colors.indices.contains(index) ? colors[index] : .black)
                        .frame(width: 70, height: 70)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
            }
        }
        .onAppear {
            randomizeStyles()
        }
    }
    
    private func randomizeStyles() {
        colors = numbers.map { _ in possibleColors.randomElement() ?? .black }
        fontSizes = numbers.map { _ in possibleFontSizes.randomElement() ?? 40 }
    }
}
