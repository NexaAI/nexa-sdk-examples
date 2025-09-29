import SwiftUI

struct ChatInputView: View {
    @State var vm: ChatInputViewModel = .init()

    @Environment(ModelManager.self) var modelManager
    @FocusState private var isFocused: Bool
    @State private var showSetting: Bool = false
    @State private var showRecoder: Bool = false

    var onSendButtonPressed: ((_ isEdit: Bool) -> Void)?
    var onTextFieldFocusedChange: ((Bool) -> Void)?
    var onStopButtonPressed: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                if vm.isEditing {
                    editView
                }
                if !vm.selectedImages.isEmpty {
                    imageItemsView
                }
                if !vm.selectedAudios.isEmpty {
                    audioItemsView
                }
                if !vm.selectedDocuments.isEmpty {
                    documentItemsView
                }

                ZStack {
                    if showRecoder {
                        VoiceBarsView(recorder: vm.audioRecorder)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 4)
                    } else {
                        promptTextField
                    }
                }

                toolBar
            }
            .padding(12)
        }
        .shadow200(24)
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
        .animation(.smooth, value: vm.text)
        .animation(.default, value: showRecoder)
        .onChange(of: isFocused) { oldValue, newValue in
            vm.isFocused = newValue
            onTextFieldFocusedChange?(newValue)
        }
        .onChange(of: vm.isFocused) { oldValue, newValue in
            isFocused = newValue
        }
        .background(Color.Background.secondary)
        .overlay(alignment: .top) {
            LinearGradient(colors: [Color.Shader.op100.opacity(0.6), .clear], startPoint: .bottom, endPoint: .top)
                .frame(height: 32)
                .offset(y: -32)
        }
    }

    // MARK: - subviews

    private var editView: some View {
        HStack(spacing: 4) {
            Image(.pen)
                .resizable()
                .safeStyle()
                .square(16)
            Text("Edit Message")
                .textStyle(.caption1(textColor: Color.Safe.font))
            Image(.x)
                .resizable()
                .primaryStyle()
                .square(16)
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .anyButton {
            vm.isEditing = false
            vm.clear()
        }
    }

    private var imageItemsView: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 4) {
                ForEach(vm.selectedImages) { item in
                    ImageItemView(item: item) {
                        vm.removeImage(item)
                    }
                }
                Spacer()
            }
            .padding(.leading, 4)
        }
        .scrollIndicators(.hidden)
    }

    private var audioItemsView: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(vm.selectedAudios) { item in
                    AudioItemView(item: item) {
                        vm.removeAudio(item)
                    }
                }
                Spacer()
            }
        }
        .scrollIndicators(.hidden)
    }

    private var documentItemsView: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(vm.selectedDocuments) { item in
                    DocumentItemView(item: item) {
                        vm.removeDocument(item)
                    }
                }
                Spacer()
            }
        }
        .scrollIndicators(.hidden)
    }


    private var promptTextField: some View {
        TextField(
            textFieldPlaceholder,
            text: $vm.text,
            prompt: Text(textFieldPlaceholder).textStyle(.body1(textColor: Color.Text.inactive)),
            axis: .vertical
        )
        .textStyle(.body1(textColor: Color.Text.primary))
        .padding(.vertical, 12)
        .padding(.leading, 4)
        .lineLimit(5)
        .disabled(!modelManager.isLoaded)
        .focused($isFocused)
        .frame(minHeight: 46)
        .contentShape(Rectangle())
    }

    private var textFieldPlaceholder: String {
        if modelManager.isLoadingModel {
            return "Loading model, please wait..."
        }
        return modelManager.isLoaded ? "Type prompt..." : "Model not loaded, Please initialize the model"
    }

    private var disablePlusButton: Bool {
        !modelManager.isLoaded // || vm.modelType == .chat
    }

    private var disableSettingButton: Bool {
        !modelManager.isLoaded
    }

    private var disableSpeechButton: Bool {
        !modelManager.isLoaded || vm.modelType == .chat
    }

    private var plusButtonFillColor: Color {
        if vm.showFileSelectView {
            return Color.Button.Tertiary.Bg.click
        }
        return disablePlusButton ? Color.Button.Tertiary.Bg.disabled : Color.Button.Tertiary.Bg.default
    }

    private var toolBar: some View {
        HStack {
            HStack(spacing: 12) {
                if !disablePlusButton {
                    actionButton(
                        .plus,
                        fillColor: plusButtonFillColor,
                        foregroundColor: disablePlusButton ? Color.Button.Tertiary.Icon.disabled : Color.Button.Tertiary.Icon.default
                    ) {
                        isFocused = false
                        Task {
                            try? await Task.sleep(for: .seconds(0.3))
                            vm.showFileSelectView = true
                        }
                    }
                    .disabled(disablePlusButton)
                    .anyPopover(isPresented: $vm.showFileSelectView, position: .topLeading, contentSize: selectedFileViewContentSize) {
                        FileSelectView(fileTypes: selectedFileItemTypes, isPresented: $vm.showFileSelectView, onSelectedPhotosPickerItems: { pickerItems in
                            vm.showFileSelectView = false
                            vm.photosPickerItems = pickerItems
                        }, onCameraImagePicked: { cameraImage in
                            vm.showFileSelectView = false
                            Task {
                                try? await Task.sleep(for: .seconds(0.2))
                                vm.appendImage(cameraImage)
                            }
                        }, onAudioPicked: { url in
                            vm.showFileSelectView = false
                            Task {
                                try? await Task.sleep(for: .seconds(0.2))
                                vm.appendAudio(from: url)
                            }
                        }, onDocumentPicked: { url in
                            vm.showFileSelectView = false
                            Task {
                                try? await Task.sleep(for: .seconds(0.2))
                                vm.appendDocument(from: url)
                            }
                        })
                        .offset(x: -12, y: -8)
                    }
                }
                actionButton(
                    .settings2,
                    fillColor: disableSettingButton ? Color.Button.Tertiary.Bg.disabled : Color.Button.Tertiary.Bg.default,
                    foregroundColor: disableSettingButton ? Color.Button.Tertiary.Icon.disabled : Color.Button.Tertiary.Icon.default)  {
                    showSetting = true
                }
                .disabled(disableSettingButton)
                .fullScreenCover(isPresented: $showSetting) {
                    GenerationSettingsView(vm: .init(modelConfigManager: modelManager.configManager, isMultiModel: vm.modelType != .chat))
                        .presentationDetents([.large])
                }
            }

            Spacer()
            ZStack {
                if vm.isGenerating {
                    actionButton(
                        .square,
                        fillColor: Color.Button.Primary.Bg.default,
                        foregroundColor: Color.Button.Primary.Icon.default
                    ) {
                        onStopButtonPressed?()
                    }
                } else if vm.enableSend {
                    actionButton(
                        .send,
                        fillColor: Color.Button.Primary.Bg.default,
                        foregroundColor: Color.Button.Primary.Icon.default
                    ) {
                        didSendButtonPressed()
                    }
                }
//                else {
//                    if showRecoder {
//                        HStack(spacing: 8) {
//                            actionButton(.x) {
//                                vm.stopRecoder(true)
//                                showRecoder = false
//                            }
//                            actionButton(.check) {
//                                vm.confirmRecoder()
//                                showRecoder = false
//                            }
//                        }
//                    } else {
//                        actionButton(
//                            .mic,
//                            fillColor: disableSpeechButton ? Color.Button.Tertiary.Bg.disabled : Color.Button.Tertiary.Bg.default,
//                            foregroundColor: disableSpeechButton ? Color.Button.Tertiary.Icon.disabled : Color.Button.Tertiary.Icon.default
//                        ) {
//                            showRecoder = true
//                            vm.startRecorder()
//                        }
//                        .disabled(disableSpeechButton)
//                    }
//                }
            }
        }
    }

    private var selectedFileItemTypes: [FileSelectView.FileType] {
        vm.modelType == .chat ? [.file] : [.camera, .photos]
    }

    private var selectedFileViewContentSize: CGSize {
        CGSize(width: FileSelectView.contentSize.width, height: CGFloat(selectedFileItemTypes.count) * FileSelectView.contentItemHeight)
    }

    private func actionButton(
        _ image: ImageResource,
        strokeColor: Color = Color.Button.Tertiary.Border.default,
        fillColor: Color = Color.Button.Tertiary.Bg.default,
        foregroundColor: Color = Color.Button.Tertiary.Icon.default,
        action: @escaping () -> Void
    ) -> some View {
        Image(image)
            .renderingMode(.template)
            .resizable()
            .foregroundStyle(foregroundColor)
            .square(16)
            .padding(8)
            .anyButton(action: action)
            .cornerRadiusBackground(with: fillColor, cornerRadius: 16, borderColor: strokeColor)
    }

    private func didSendButtonPressed() {
        isFocused = false
        onSendButtonPressed?(vm.isEditing)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//            onSendButtonPressed?(vm.isEditing)
//        }
    }
}

struct DocumentItemView: View {
    let item: ChatInputViewModel.DocumentItem
    var onDeleteButtonPressed: (() -> Void)?
    var body: some View {
        HStack(spacing: 10) {
            Image(.fileText)
                .renderingMode(.template)
                .resizable()
                .foregroundStyle(.brand7)
                .aspectRatio(contentMode: .fill)
                .square(24)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.url.name)
                    .textStyle(.caption1())
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Text(item.url.type)
                    Text(item.url.sizeStr)
                }
                .textStyle(.caption2(textColor: Color.Text.tertiary))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 3)
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.clear)
                .stroke(Color.Component.Border.secondary, lineWidth: 1)
        )
        .frame(width: 220)
        .overlay(alignment: .topTrailing) {
            Image(.x)
                .buttonDefaultStyle()
                .square(20)
                .background(
                    Circle().fill(Color.Button.Default.Bg.default)
                )
                .offset(x: -4, y: 4)
                .anyButton {
                    withAnimation(.smooth) {
                        onDeleteButtonPressed?()
                    }
                }
        }
    }
}


struct AudioItemView: View {
    let item: ChatInputViewModel.AudioItem
    var onDeleteButtonPressed: (() -> Void)?
    var body: some View {
        HStack(spacing: 10) {
            Image(.fileAudio)
                .renderingMode(.template)
                .resizable()
                .foregroundStyle(.brand7)
                .aspectRatio(contentMode: .fill)
                .square(24)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.audioURL.name)
                    .textStyle(.caption1())
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Text(item.audioURL.type)
                    Text(item.audioURL.sizeStr)
                }
                .textStyle(.caption2(textColor: Color.Text.tertiary))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 3)
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.clear)
                .stroke(Color.Component.Border.secondary, lineWidth: 1)
        )
        .frame(width: 220)
        .overlay(alignment: .topTrailing) {
            Image(.x)
                .buttonDefaultStyle()
                .square(20)
                .background(
                    Circle().fill(Color.Button.Default.Bg.default)
                )
                .offset(x: -4, y: 4)
                .anyButton {
                    withAnimation(.smooth) {
                        onDeleteButtonPressed?()
                    }
                }
        }
    }
}

struct ImageItemView: View {
    let item: ChatInputViewModel.ImageItem
    var onDeleteButtonPressed: (() -> Void)?
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: item.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .square(100)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.clear)
                .stroke(Color.ImageBox.border, lineWidth: 1)
        )
        .overlay(alignment: .topTrailing) {
            Image(.x)
                .buttonDefaultStyle()
                .square(20)
                .background(
                    Circle().fill(Color.Button.Default.Bg.default)
                )
                .offset(x: -4, y: 4)
                .anyButton {
                    withAnimation(.smooth) {
                        onDeleteButtonPressed?()
                    }
                }
        }
    }
}
#Preview {
    @Previewable @State var prompt: String = ""
    ChatInputView()
        .previewEnvironment()
}

#Preview("Audio Item") {
    AudioItemView(item: .init(audioURL: .init(string: "http://www.helloworld.com/test-2.mp3")!))
}
#Preview("Image Item") {
    ImageItemView(item: .init(id: "abc", image: .audioLines))
}
