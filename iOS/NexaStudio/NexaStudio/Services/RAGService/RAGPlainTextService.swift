import Foundation
import NexaAI

class RAGPlainTextService: RAGService {
    let embedder: TextEmbeddable
    let chunker: Chunker

    init(embedder: any TextEmbeddable,
         chunker: Chunker = ParagraphChunker()) {
        self.embedder = embedder
        self.chunker = chunker
    }

    func retrieve(from document: URL, query: String, topK: Int = 10) async throws -> [String] {
        let text = try loadDocument(document)
        return try retrieve(from: text, query: query, topK: topK)
    }

    func retrieve(from text: String, query: String, topK: Int = 10) throws -> [String] {
        let slices = slice(text: text)
        let index = try embed(texts: slices)
        let queryEmbedding = try embed(text: query)

        let scored = index.map { ($0.chunk, self.cosineSimilarity($0.embedding, queryEmbedding)) }
        let sorted = scored.sorted { $0.1 > $1.1 }
        return Array(sorted.prefix(topK).map { $0.0 })
    }

    private func loadDocument(_ documentURL: URL) throws -> String {
        try String(contentsOf: documentURL)
    }
}
