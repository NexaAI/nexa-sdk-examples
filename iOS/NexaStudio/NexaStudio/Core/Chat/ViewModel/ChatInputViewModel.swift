import PhotosUI
import SwiftUI

@Observable
@MainActor
class ChatInputViewModel {

    struct ImageItem: Identifiable {
        let id: String
        let image: UIImage
        init(id: String, image: UIImage) {
            self.id = id
            self.image = image
        }
        
        init(url: URL) {
            self.image = UIImage(contentsOfFile: url.path()) ?? .init()
            self.id = UUID().uuidString
        }
    }

    struct AudioItem: Identifiable {
        let id: String
        let audioURL: URL

        init(id: String = UUID().uuidString, audioURL: URL) {
            self.id = id
            self.audioURL = audioURL
        }
    }

    struct DocumentItem: Identifiable {
        let id: String
        let url: URL

        init(id: String = UUID().uuidString, url: URL) {
            self.id = id
            self.url = url
        }
    }

    var text: String = ""
    var showFileSelectView: Bool = false
    var isGenerating: Bool = false
    var isFocused: Bool = false
    var modelType: ModelType = .chat
    var isEditing: Bool = false

    var audioRecorder: AudioRecorder = .init()

    var selectedImages: [ImageItem] = []
    var selectedAudios: [AudioItem] = []
    var selectedDocuments: [DocumentItem] = []

    var photosPickerItems: [PhotosPickerItem] = [] {
        didSet {
            didPhotosPickerItemsChange(photosPickerItems)
        }
    }

    func clear() {
        text = ""
        selectedImages = []
        selectedAudios = []
        selectedDocuments = []
    }

    func removeImage(_ image: ImageItem) {
        selectedImages.removeAll { image.id == $0.id }
    }

    func removeAudio(_ audio: AudioItem) {
        selectedAudios.removeAll { audio.id == $0.id }
    }

    func removeDocument(_ doc: DocumentItem) {
        selectedDocuments.removeAll { doc.id == $0.id }
    }

    func startRecorder() {
        audioRecorder.startRecording()
    }

    func stopRecoder(_ clear: Bool = false) {
        audioRecorder.stopRecording(clear)
    }

    func confirmRecoder() {
        audioRecorder.stopRecording()
        if let audioUrl = audioRecorder.recordedFileURL {
            appendAudio(from: audioUrl)
        }
    }

    func saveAndGetImageUrls() -> [URL] {
        selectedImages.compactMap {
           try? FileStoreManager.saveImage($0.image, named: $0.id)
        }
    }

    func appendImage(_ image: UIImage) {
        selectedImages.append(.init(id: UUID().uuidString, image: image))
    }

    func appendDocument(from url: URL) {
        do {
            let fileUrl = try FileStoreManager.copyDocument(from: url)
            selectedDocuments.append(.init(url: fileUrl))
        } catch {
            Log.error(error)
        }
    }

    func appendAudio(from url: URL) {
        do {
            let fileUrl = try FileStoreManager.copyAudio(from: url)
            selectedAudios.append(.init(audioURL: fileUrl))
        } catch {
            Log.error(error)
        }
    }

    var enableSend: Bool {
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if modelType == .chat {
            return !text.isEmpty
        }
        return !text.isEmpty || !selectedImages.isEmpty || !selectedAudios.isEmpty
    }

    private func didPhotosPickerItemsChange(_ photosPickerItems: [PhotosPickerItem]) {
        if photosPickerItems.isEmpty {

        } else {
            showFileSelectView = false
            appendImage(from: photosPickerItems)
            self.photosPickerItems = []
        }
    }

    private func appendImage(from photosPickerItems: [PhotosPickerItem]) {
        guard !photosPickerItems.isEmpty else {
            selectedImages = []
            return
        }
        Task {
            for selectedItem in photosPickerItems {
                if let data = try? await selectedItem.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedImages.append(.init(id: selectedItem.itemIdentifier ?? UUID().uuidString, image: uiImage))
                }
            }
        }
    }
}
