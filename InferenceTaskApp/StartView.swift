//
//  StartView.swift
//  InferenceTaskApp
//
//  Created by Giorgio Varesco on 2025-05-25.
//

import SwiftUI

struct StartView: View {
    @State private var userName: String = ""
    @State private var testDuration: String = "1"
    @State private var parsedDuration: Int = 1
    @State private var showInfoAlert: Bool = false
    @State private var startCMSITOnly = false
    @State private var startFullProtocol = false
    @State private var allTrials: [Trial] = []

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: geometry.size.height * 0.02) {
                    Spacer(minLength: geometry.size.height * 0.05)

                    Text("Multi-Source Inference Task")
                        .font(.system(size: geometry.size.width * 0.06, weight: .bold))
                        .multilineTextAlignment(.center)

                    TextField("Enter your name", text: $userName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    TextField("Duration (minutes)", text: $testDuration)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    // Navigation Links
                    NavigationLink(
                        destination: TestView(
                            userName: userName,
                            testDuration: parsedDuration,
                            isPartOfFullProtocol: false,
                            prePVTTrials: [],
                            allTrials: $allTrials
                        ),
                        isActive: $startCMSITOnly
                    ) { EmptyView() }

                    NavigationLink(
                        destination: PVTView(
                            userName: userName,
                            testDuration: 3, // for PVT itself
                            isPreTest: true,
                            allTrials: $allTrials,
                            cMSITDuration: parsedDuration 
                        ),
                        isActive: $startFullProtocol
                    ) { EmptyView() }

                    // Instructions
                    Group {
                        Text("Of the three numbers, one is different...")
                        Text("Parmi les trois nombres, un est différent...")
                            .foregroundColor(.cyan)
                    }
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                    // Start buttons
                    Button("Start cMSIT Only") {
                        startProtocol(onlyCMSIT: true)
                    }
                    .padding()
                    .frame(width: geometry.size.width * 0.7)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)

                    Button("Start Full Protocol (PVT + cMSIT + PVT)") {
                        startProtocol(onlyCMSIT: false)
                    }
                    .padding()
                    .frame(width: geometry.size.width * 0.7)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)

                    Spacer()
                }
                .padding()
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showInfoAlert = true }) {
                            Image(systemName: "info.circle")
                        }
                        .accessibilityLabel("App information")
                    }
                }
                .alert(isPresented: $showInfoAlert) {
                    Alert(
                        title: Text("App Information"),
                        message: Text("Version 1.1\nCredit: Giorgio Varesco, PhD\nOrcID: 0000-0001-9385-6972"),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
    }

    // MARK: - Protocol Start Logic
    func startProtocol(onlyCMSIT: Bool) {
        guard let duration = Int(testDuration), !userName.isEmpty else { return }
        parsedDuration = duration

        if onlyCMSIT {
            startCMSITOnly = true
        } else {
            startFullProtocol = true
        }
    }
}
