//
//  TestView.swift
//  InferenceTaskApp
//
//  Created by Giorgio Varesco on 2025-05-25.
//

import SwiftUI

struct TestView: View {
    let userName: String
    let testDuration: Int
    let isPartOfFullProtocol: Bool
    let prePVTTrials: [Trial]
    @Binding var allTrials: [Trial]

    @State private var currentTrial = 1
    @State private var startTime = Date()
    @State private var testStartTime = Date()
    @State private var trials: [Trial] = []
    @State private var showResults = false
    @State private var numbers: [NumberDisplay] = []
    @State private var correctIndex: Int = 0
    @State private var navigateToPostPVT = false
    @State private var didAppendPrePVT = false // ← ADD THIS

    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    let allColors: [Color] = [.red, .indigo]

    var body: some View {
        VStack {
            if showResults {
                if isPartOfFullProtocol {
                    NavigationLink(
                        destination: PVTView(
                            userName: userName,
                            testDuration: 3,
                            isPreTest: false,
                            allTrials: $allTrials,
                            cMSITDuration: testDuration,
                        ),
                        isActive: $navigateToPostPVT
                    ) {
                        EmptyView()
                    }
                    .onAppear {
                        allTrials.append(contentsOf: trials)
                        navigateToPostPVT = true
                    }
                } else {
                    ResultView(
                        results: trials,
                        participantID: userName,
                        startTime: testStartTime
                    )
                }
            } else {
                Text("Trial \(currentTrial)")
                    .font(.headline)
                    .padding()

                HStack {
                    ForEach(Array(numbers.enumerated()), id: \.1.id) { idx, num in
                        Button(action: { handleAnswer(idx) }) {
                            Text("\(num.value)")
                                .font(.system(size: num.fontSize))
                                .foregroundColor(num.color)
                                .frame(width: 80, height: 80)
                        }
                    }
                }
                .onAppear {
                    testStartTime = Date()
                    if isPartOfFullProtocol && !didAppendPrePVT {
                        allTrials.append(contentsOf: prePVTTrials)
                        didAppendPrePVT = true
                    }
                    generateTrial()
                }
                .onReceive(timer) { _ in
                    if Date().timeIntervalSince(testStartTime) >= Double(testDuration) * 60 {
                        showResults = true
                    }
                }
            }
        }
    }

    func generateTrial() {
        let same = Int.random(in: 1...9)
        var odd = Int.random(in: 1...9)
        while odd == same { odd = Int.random(in: 1...9) }

        correctIndex = Int.random(in: 0...2)
        var values = [same, same, same]
        values[correctIndex] = odd

        numbers = values.map {
            NumberDisplay(
                value: $0,
                fontSize: CGFloat.random(in: 40...120),
                color: allColors.randomElement()!
            )
        }
        startTime = Date()
    }

    func handleAnswer(_ index: Int) {
        let rt = Date().timeIntervalSince(startTime) * 1000
        let isCorrect = index == correctIndex
        trials.append(
            Trial(
                trialNumber: currentTrial,
                responseTime: rt,
                isCorrect: isCorrect,
                combination: numbers.map { "\($0.value)" }.joined()
            )
        )
        currentTrial += 1
        generateTrial()
    }
}
