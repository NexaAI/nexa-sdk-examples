import Foundation

protocol Chunker {
    func chunk(text: String) -> [String]
}

struct SentenceChunker: Chunker {
    func chunk(text: String) -> [String] {
        let separators: CharacterSet = [".", "?", "！", "!", "？", "。"]
        var sentences: [String] = []
        var current = ""

        for char in text {
            current.append(char)
            if char.unicodeScalars.contains(where: { separators.contains($0) }) {
                let sentence = current.trimmingCharacters(in: .whitespacesAndNewlines)
                if !sentence.isEmpty {
                    sentences.append(sentence)
                }
                current = ""
            }
        }

        if !current.isEmpty {
            sentences.append(current.trimmingCharacters(in: .whitespacesAndNewlines))
        }

        return sentences
    }
}

struct ParagraphChunker: Chunker {
    func chunk(text: String) -> [String] {
        text
            .components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}

struct FixedLengthChunker: Chunker {
    let size: Int
    let overlap: Int
    init(size: Int = 200, overlap: Int = 50) {
        self.size = size
        self.overlap = overlap
    }

    func chunk(text: String) -> [String] {
        var chunks: [String] = []
        var start = text.startIndex

        while start < text.endIndex {
            let end = text.index(start, offsetBy: size, limitedBy: text.endIndex) ?? text.endIndex
            let chunk = String(text[start..<end]).trimmingCharacters(in: .whitespacesAndNewlines)
            if !chunk.isEmpty {
                chunks.append(chunk)
            }
            if end == text.endIndex { break }
            start = text.index(start, offsetBy: size - overlap, limitedBy: text.endIndex) ?? text.endIndex
        }
        return chunks
    }
}
