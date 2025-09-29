import Foundation
import NexaAI

protocol TextEmbeddable {
    func embed(text: String) throws -> [Float]
}

protocol RAGService {
    var embedder: TextEmbeddable { get }
    var chunker: Chunker { get }
    func retrieve(from document: URL, query: String, topK: Int) async throws -> [String]
}


extension Embedder: TextEmbeddable {

    func embed(text: String) throws -> [Float] {
        let config = EmbeddingConfig(
            batchSize: 1,
            normalize: true,
            normalizeMethod: .l2
        )
        let embeddings = try embed(texts: [text], config: config).embeddings
        return embeddings.first ?? []
    }
}

import NaturalLanguage
import Accelerate

extension NLEmbedding: TextEmbeddable {
    func embed(text: String) throws -> [Float] {
        guard let embedding = NLEmbedding.wordEmbedding(for: .english) else {
            print("ERROR: Failed to get NLEmbedding for English")
            return []
        }

        let words = text.lowercased().split(separator: " ").map { String($0) }
        guard !words.isEmpty else {
            print("ERROR: No words found in sentence")
            return []
        }

        var validVectors: [[Float]] = []

        for word in words {
            if let vector = embedding.vector(for: word) {
                let f = Array(vector.map { Float($0) })
                validVectors.append(f)
            }
        }

        guard !validVectors.isEmpty else {
            return []
        }

        let vectorLength = validVectors[0].count
        var vectorSum = [Float](repeating: 0, count: vectorLength)

        for vector in validVectors {
            vDSP_vadd(vectorSum, 1, vector, 1, &vectorSum, 1, vDSP_Length(vectorSum.count))
        }

        var vectorAverage = [Float](repeating: 0, count: vectorSum.count)
        var divisor = Float(validVectors.count)
        vDSP_vsdiv(vectorSum, 1, &divisor, &vectorAverage, 1, vDSP_Length(vectorAverage.count))

        return vectorAverage
    }
}

extension RAGService {

    func slice(text: String) -> [String] {
        chunker.chunk(text: text)
    }

    func embed(text: String) throws -> [Float] {
        try embedder.embed(text: text)
    }

    func embed(texts: [String]) throws -> [(chunk: String, embedding: [Float])] {
        var embeddings: [[Float]] = .init()
        for text in texts {
            let embedding = try embed(text: text)
            embeddings.append(embedding)
        }

        if embeddings.count != texts.count {
            return []
        }
        return Array(zip(texts, embeddings))
    }

    func cosineSimilarity(_ a: [Float], _ b: [Float]) -> Float {
        guard a.count == b.count else { return -1 }
        let dot = zip(a, b).map(*).reduce(0, +)
        let normA = sqrt(a.map { $0 * $0 }.reduce(0, +))
        let normB = sqrt(b.map { $0 * $0 }.reduce(0, +))
        return dot / (normA * normB)
    }
}
