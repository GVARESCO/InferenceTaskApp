//
//  ResultView.swift
//  InferenceTaskApp
//
//  Created by Giorgio Varesco on 2025-05-25.
//

//
//  ResultView.swift
//  InferenceTaskApp
//
//  Created by Giorgio Varesco on 2025-05-25.
//

import SwiftUI
import UniformTypeIdentifiers

struct ResultView: View {
    let results: [Trial]
    let participantID: String
    let startTime: Date

    @State private var showExport = false
    @State private var exportURL: URL?

    var body: some View {
        VStack {
            Text("Results for \(participantID)").font(.title)
            List(results) { trial in
                HStack {
                    Text("Trial \(trial.trialNumber)")
                    Spacer()
                    Text(String(format: "%.0f ms", trial.responseTime))
                    Spacer()
                    Image(systemName: trial.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(trial.isCorrect ? .green : .red)
                }
            }
            Button("Export CSV", action: exportCSV)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .fileExporter(isPresented: $showExport, document: CSVDocument(url: exportURL), contentType: .commaSeparatedText, defaultFilename: "Results_\(participantID)") { _ in }
    }

    func exportCSV() {
        let formatter = ISO8601DateFormatter()
        let header = "ParticipantID,StartTime,Trial,ResponseTime_ms,IsCorrect,Combination\n"
        let rows = results.map {
            "\(participantID),\(formatter.string(from: startTime)),\($0.trialNumber),\(String(format: "%.0f", $0.responseTime)),\($0.isCorrect),\($0.combination)"
        }
        let csv = header + rows.joined(separator: "\n")
        let filename = "Results_\(participantID)_\(Int(Date().timeIntervalSince1970)).csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        try? csv.write(to: url, atomically: true, encoding: .utf8)
        exportURL = url
        showExport = true
    }
}
