//
//  PVTView.swift
//  InferenceTaskApp
//
//  Created by Giorgio Varesco on 2025-05-27.
//

import SwiftUI

struct PVTView: View {
    let userName: String
    let testDuration: Int
    let isPreTest: Bool
    @Binding var allTrials: [Trial]
    let cMSITDuration: Int

    @State private var trials: [PVTTrial] = []
    @State private var testStartTime = Date()
    @State private var stimulusTime = Date()
    @State private var showingStimulus = false
    @State private var isFinished = false
    @State private var navigateToCMSIT = false
    @State private var navigateToResults = false
    @State private var screenTapped = false
    @State private var elapsedMs = 0

    @State private var timer: Timer? = nil
    @State private var waitTimer: Timer? = nil

    var body: some View {
        NavigationStack {
            VStack {
                if isFinished {
                    ProgressView("Processing…")
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                if isPreTest {
                                    navigateToCMSIT = true
                                } else {
                                    navigateToResults = true
                                }
                            }
                        }
                } else {
                    ZStack {
                        Color.white
                            .edgesIgnoringSafeArea(.all)

                        if showingStimulus {
                            Circle()
                                .fill(Color.black)
                                .frame(width: 150, height: 150)
                                .overlay(
                                    Text("\(elapsedMs) ms")
                                        .foregroundColor(.red)
                                        .font(.system(size: 30, weight: .bold, design: .monospaced))
                                )
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        handleTap()
                    }
                    .onAppear {
                        testStartTime = Date()
                        startNextTrial()
                    }
                }

                NavigationLink(
                    destination: TestView(
                        userName: userName,
                        testDuration: cMSITDuration, 
                        isPartOfFullProtocol: true,
                        prePVTTrials: trials.map { $0.toTrial() },
                        allTrials: $allTrials
                    ),
                    isActive: $navigateToCMSIT
                ) { EmptyView() }

                NavigationLink(
                    destination: ResultView(
                        results: allTrials + trials.map { $0.toTrial() },
                        participantID: userName,
                        startTime: testStartTime
                    ),
                    isActive: $navigateToResults
                ) { EmptyView() }
            }
        }
    }

    func startNextTrial() {
        screenTapped = false
        waitTimer?.invalidate()
        timer?.invalidate()
        elapsedMs = 0

        let delay = Double.random(in: 2.0...5.0)
        waitTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
            stimulusTime = Date()
            showingStimulus = true

            timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { _ in
                let diff = Date().timeIntervalSince(stimulusTime)
                elapsedMs = Int(diff * 1000)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                if showingStimulus {
                    trials.append(PVTTrial(timestamp: Date(), responseTime: nil, wasFalseStart: false))
                    showingStimulus = false
                    timer?.invalidate()
                    waitAndStartNextTrial()
                }
            }
        }
    }

    func handleTap() {
        if isFinished { return }

        let now = Date()
        screenTapped = true

        if showingStimulus {
            let reactionTime = now.timeIntervalSince(stimulusTime) * 1000
            trials.append(PVTTrial(timestamp: now, responseTime: reactionTime, wasFalseStart: false))
            timer?.invalidate()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showingStimulus = false
                waitAndStartNextTrial()
            }

        } else {
            trials.append(PVTTrial(timestamp: now, responseTime: nil, wasFalseStart: true))
            timer?.invalidate()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showingStimulus = false
                waitAndStartNextTrial()
            }
        }
    }

    func waitAndStartNextTrial() {
        if Date().timeIntervalSince(testStartTime) >= Double(testDuration) * 60 {
            isFinished = true
        } else {
            startNextTrial()
        }
    }
}

struct PVTTrial: Identifiable {
    let id = UUID()
    let timestamp: Date
    let responseTime: Double?
    let wasFalseStart: Bool

    func toTrial() -> Trial {
        Trial(
            trialNumber: 0, // Fill in sequence elsewhere if needed
            responseTime: responseTime ?? -1,
            isCorrect: !wasFalseStart && responseTime != nil,
            combination: wasFalseStart ? "FalseStart" : "PVT"
        )
    }
}
