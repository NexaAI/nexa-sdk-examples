
import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct FileImpoter {
    var contentType: [UTType]
    var onCompletion: (Result<URL, any Error>) -> Void
}

extension View {

    func fileImpoter(_ fileImpoter: Binding<FileImpoter?>) -> some View {
        fileImporter(isPresented: .init(fileImpoter), allowedContentTypes: fileImpoter.wrappedValue?.contentType ?? [.item], onCompletion: fileImpoter.wrappedValue?.onCompletion ?? {_ in })
    }

}
