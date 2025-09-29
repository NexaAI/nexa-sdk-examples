import SwiftUI
import PhotosUI

struct FileSelectView: View {

    var fileTypes: [FileType] = [.camera, .photos, .file]

    static let contentItemHeight: CGFloat = 50
    static let contentSize: CGSize = .init(width: 246, height: 150)

    @Binding var isPresented: Bool

    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var showCamera: Bool = false
    @State private var fileImpoter: FileImpoter?

    var onSelectedPhotosPickerItems: (([PhotosPickerItem]) -> Void)?
    var onCameraImagePicked: ((UIImage) -> Void)?
    var onAudioPicked: ((URL) -> Void)?
    var onDocumentPicked: ((URL) -> Void)?

    var body: some View {
        VStack {
            if fileTypes.contains(.audio) {
                audioPickerView
            }
            if fileTypes.contains(.camera) {
                cameraPickerView
            }
            if fileTypes.contains(.photos) {
                photoPickerView
            }
            if fileTypes.contains(.file) {
                textPickerView
            }
        }
        .shadow400(8, backgroundColor: Color.Menu.Bg.default, strokeColor: Color.Menu.Border.default)
        .frame(width: Self.contentSize.width)
        .onChange(of: selectedItems, { oldValue, newValue in
            onSelectedPhotosPickerItems?(newValue)
        })
        .fullScreenCover(isPresented: $showCamera) {
            CameraView { image in
                onCameraImagePicked?(image)
            } onCancel: {
                isPresented = false
            }
            .ignoresSafeArea()
        }
        .fileImpoter($fileImpoter)
    }

    private var textPickerView: some View {
        HStack(alignment: .center) {
            FileType.file.buildItem
        }
        .contentShape(Rectangle())
        .anyButton(.background) {
            fileImpoter = .init(contentType: [.text, .plainText, .json, .html, .script, .swiftSource, .pdf]) { result in
                do {
                    let url = try result.get()
                    onDocumentPicked?(url)
                } catch {
                    Log.error(error)
                }
            }
        }
    }

    private var audioPickerView: some View {
        HStack(alignment: .center) {
            FileType.file.buildItem
        }
        .anyButton(.background) {
            fileImpoter = .init(contentType: [.mp3, .audio, .mpeg4Audio]) { result in
                do {
                    let url = try result.get()
                    onAudioPicked?(url)
                } catch {
                    Log.error(error)
                }
            }
        }
    }

    private var cameraPickerView: some View {
        HStack(alignment: .center) {
            FileType.camera.buildItem
        }
        .anyButton {
            Task {
                let isAllow = await PermissionManager.checkCameraPermission()
                if isAllow {
                    showCamera = true
                } else {
                    isPresented = false
                    showAlert()
                }
            }
        }
    }

    private func showAlert() {
        AnyAlertManager.shared.alert = .init(
            title: "Permission Setting",
            subtitle: "Camera access has been denied. Please enable it in Settings.",
            buttons: {
                AnyView(
                    Group {
                        Button("Cancel", role: .cancel) { }
                        Button("Setting") {
                            Router.openAppSettings()
                        }
                    }
                )
            }
        )
    }

    private var photoPickerView: some View {
        PhotosPicker(selection: $selectedItems, matching: .images) {
            FileType.photos.buildItem
        }
    }

    enum FileType: CaseIterable {
        case file
        case camera
        case photos
        case audio

        var data: (title: String, icon: ImageResource) {
            switch self {
            case .audio:
                return ("Audio",  .fileAudio)
            case .file:
                return ("Add File(Plain Text or Pdf)",  .fileText)
            case .camera:
                return ("Camera", .camera)
            case .photos:
                return ("Photos", .imageGray)
            }
        }

        var buildItem: some View {
            MenuItemView(title: data.title, icon: data.icon)
        }
    }
}

#Preview("FileSelectView"){
    @Previewable @State var prompt: String = ""
    VStack {
        FileSelectView(isPresented: .constant(false))
    }
}
