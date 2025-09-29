import Foundation
import PDFKit
import NexaAI

class RAGPdfService: RAGService {
    let embedder: any TextEmbeddable
    let chunker: any Chunker

    init(embedder: any TextEmbeddable,
         chunker: any Chunker = FixedLengthChunker()
    ) {
        self.embedder = embedder
        self.chunker = chunker
    }

    func retrieve(from document: URL, query: String, topK: Int = 3) async throws -> [String] {
        let pages = extract(url: document).pages

        var indexs: [(chunk: String, embedding: [Float])] = .init()
        for page in pages {
            let slices = slice(text: page)
            let index = try embed(texts: slices)
            indexs.append(contentsOf: index)
        }

        let queryEmbedding = try embed(text: query)

        let scored = indexs.map { ($0.chunk, self.cosineSimilarity($0.embedding, queryEmbedding)) }
        let sorted = scored.sorted { $0.1 > $1.1 }
        return Array(sorted.prefix(topK).map { $0.0 })
    }

    private func extract(url: URL) -> (pages: [String], title: String) {
        guard let doc = PDFDocument(url: url) else { return ([], url.lastPathComponent) }
        var pages: [String] = []
        for i in 0..<doc.pageCount {
            guard let page = doc.page(at: i) else { continue }
            let text = (page.string ?? "").replacingOccurrences(of: "\u{00A0}", with: " ")
            if text.isEmpty { continue }
            pages.append(text)
        }
        let title = doc.documentAttributes?[PDFDocumentAttribute.titleAttribute] as? String ?? url.deletingPathExtension().lastPathComponent
        return (pages, title)
    }
}
