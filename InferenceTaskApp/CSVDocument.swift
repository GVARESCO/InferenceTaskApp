//
//  CSVDocument.swift
//  InferenceTaskApp
//
//  Created by Giorgio Varesco on 2025-05-25.
//

import SwiftUI
import UniformTypeIdentifiers

struct CSVDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.commaSeparatedText] }
    var url: URL?

    init(url: URL?) {
        self.url = url
    }

    init(configuration: ReadConfiguration) throws {}

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let url else {
            throw CocoaError(.fileNoSuchFile)
        }
        let data = try Data(contentsOf: url)
        return FileWrapper(regularFileWithContents: data)
    }
}
