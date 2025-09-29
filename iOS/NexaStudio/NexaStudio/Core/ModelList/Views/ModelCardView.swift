
import SwiftUI

struct ModelCardView: View {
    @Environment(ModelDownloadManager.self) var downloadManager
    @Environment(ModelManager.self) var modelManager

    var model: ModelInfo
    var item: ModelDownloadItem
    @State var currentRunModel: ModelInfo?

    @State private var isLoadingModel: Bool = false
    @State private var modelLoadProgress: Float = 0

    var onFinishLoadingModel: (() -> Void)?
    var onRemoveButtonPressed: (() -> Void)?
    var onDownloadError: ((String) -> Void)?

    func startDownload() {
        downloadManager.addDownload(item)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            modelName
            if item.status == .downloading {
                downloadStatusView
                    .padding(.top, 12)
            } else {
                sizeAndParameters
                    .padding(.top, 6)
//                features
//                    .padding(.top, 16)
            }
        }
        .padding(12)
        .backgroundWithRoundedRectangle(Color.Card.bg, 12)
        .overlay(alignment: .top) {
            if isLoadingModel {
                ProgressBar(
                    progress: modelLoadProgress,
                    trackTintColor: .clear
                )
                .scaleEffect(y: 0.8)
            }
        }
        .clipShape(.rect(cornerRadius: 12))
        .onChange(of: modelManager.isLoadingModel) { oldValue, newValue in
            if isLoadingModel, newValue == false {
                isLoadingModel = false
                modelLoadProgress = 0
                onFinishLoadingModel?()
            }
        }
        .onChange(of: item.errorDesc) { _, newValue in
            if let newValue, !newValue.isEmpty {
                onDownloadError?(newValue)
            }
        }
    }

    private var downloadStatusView: some View {
        VStack(spacing: 18) {
            ProgressBar(
                progress: Float(item.downloadProgress) / 100.0,
                trackTintColor: UIColor.Progress.bgDefault)
            HStack(spacing: 12){
                HStack(spacing: 4) {
                    Image(.download)
                        .resizable()
                        .tertiaryStyle()
                        .square(12)
                    Text("\(item.totalBytesWrittenFormatStr) / \(model.sizeFormatStr)")
                }

                HStack(spacing: 4){
                    Image(.zap)
                        .resizable()
                        .tertiaryStyle()
                        .square(12)
                    Text(item.speedFormatStr)
                }

                HStack(spacing: 4) {
                    Image(.hourglass)
                        .resizable()
                        .tertiaryStyle()
                        .square(12)
                    Text("\(item.remainingTimeFormatStr) left")
                }
            }
            //.textStyle(.caption2(textColor: .gray8))
            .font(.system(size: 10, weight: .regular))
            .foregroundStyle(Color.Text.secondary)
            .monospacedDigit()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var modelName: some View {
        HStack {
            Text(model.name)
                .textStyle(.subtitle2())
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            ZStack {
                if model.isComplete {
                    runView
                } else {
                    switch item.status {
                    case .notStarted:
                        downloadView
                    case .downloading:
                        downloadingView
                    case .completed:
                        runView
                    case .failed:
                        downloadView
                    case .cancelled:
                        downloadView
                    }
                }
            }
        }
    }

    private var runView: some View {
        HStack(spacing: 0) {
            Image(.trash2)
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(currentRunModel == model ? Color.Icon.disabled : Color.Icon.primary )
                .square(16)
                .padding(.horizontal, 8)
                .contentShape(Rectangle())
                .anyButton {
                    downloadManager.remove(item)
                    onRemoveButtonPressed?()
                }
                .disabled(currentRunModel == model)

            if isLoadingModel {
                Text("Loading...")
                    .textStyle(.body1(textColor: Color.Button.Secondary.Text.default))
                    .padding(.vertical, 4)
                    .padding(.horizontal, 12)
                    .frame(height: 24)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.Button.Secondary.Bg.default)
                            .stroke(Color.Button.Secondary.Border.default, lineWidth: 1)
                    )
            } else {
                runButton
                    .anyButton {
                        didRunButtonPressed()
                    }
                    .disabled(currentRunModel == model)
            }
        }
    }

    private var unloadButton: some View {
        HStack(spacing: 4) {
            Image(.circleArrowOutDownRight)
                .resizable()
                .buttonSecondaryStyle()
                .square(16)
            Text("Unload")
                .textStyle(.body1(textColor: Color.Button.Secondary.Text.default))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .frame(height: 24)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.Button.Secondary.Bg.default)
                .stroke(Color.Button.Secondary.Border.default, lineWidth: 1)
        )
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var runButton: some View {
        let disabled = currentRunModel == model
        let iconColor = disabled ? Color.Button.Secondary.Icon.disabled : Color.Button.Secondary.Icon.default
        let textColor = disabled ? Color.Button.Secondary.Text.disabled : Color.Button.Secondary.Text.default
        let bgColor = disabled ? Color.Button.Secondary.Bg.disabled : Color.Button.Secondary.Bg.default
        let borderColor = disabled ? Color.Button.Secondary.Border.disabled : Color.Button.Secondary.Border.default
        HStack(spacing: 4) {
            Image(.circleArrowOutUpRight)
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(iconColor)
                .square(16)
            Text("Run")
                .textStyle(.body1(textColor: textColor))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .frame(height: 24)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(bgColor)
                .stroke(borderColor, lineWidth: 1)
        )
        .contentShape(Rectangle())
    }

    private func didUnloadButtonPressed() {
        if modelManager.isLoadingModel {
            return
        }
        Task {
            await modelManager.unload()
            modelManager.currentModelInfo = nil
            currentRunModel = nil
        }
    }

    private func didRunButtonPressed() {
        if modelManager.isLoadingModel {
            return
        }
        isLoadingModel = true
        onModelLoading()
        modelManager.currentModelInfo = model
    }

    private func onModelLoading() {
        Task {
            withAnimation(nil) {
                modelLoadProgress = 0
            }
            while modelLoadProgress < 0.95 {
                let increment = Float.random(in: 0.1...0.5)
                withAnimation(.smooth) {
                    modelLoadProgress = min(modelLoadProgress + increment, 0.95)
                }
                try? await Task.sleep(for: .seconds(0.2))
            }
        }
    }

    private var downloadingView: some View {
        HStack(spacing: 4) {
            Image(.x)
                .resizable()
                .buttonSecondaryStyle()
                .square(16)
            Text("Cancel")
                .textStyle(.body2(textColor: Color.Button.Secondary.Text.default))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 2)
        .frame(height: 24)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.Button.Secondary.Bg.default)
                .stroke(Color.Button.Secondary.Border.default, lineWidth: 1)
        )
        .contentShape(Rectangle())
        .anyButton {
            downloadManager.cancel(item)
        }
    }

    private var downloadView: some View {
        HStack(spacing: 4) {
            Image(.download)
                .resizable()
                .buttonPrimaryStyle()
                .square(16)
            Text("Download")
                .textStyle(.body2(textColor: Color.Button.Primary.Text.default))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .backgroundWithRoundedRectangle(Color.Button.Primary.Bg.default, 12)
        .contentShape(Rectangle())
        .anyButton {
            startDownload()
        }
    }

    private var sizeAndParameters: some View {
        HStack(spacing: 8) {
            if currentRunModel == model {
                HStack(spacing: 0){
                    Image(.check)
                        .resizable()
                        .brandStyle()
                        .square(16)
                    Text("Current")
                        .textStyle(.caption1())
                }
                .padding(.horizontal, 6)
                .cornerRadiusBackground(with: Color.Component.Fills.primary, cornerRadius: 8)
            }
            Text("size: \(model.sizeFormatStr)")
            Text("Parameters: \(model.params) ")
        }
        .textStyle(.caption1(textColor: Color.Text.secondary))
        .lineLimit(1)
    }

    private var features: some View {
        HStack {
            ForEach(model.features ?? [], id: \.self) { item in
                Text(item)
                    .textStyle(.caption1(textColor: Color.Text.secondary))
                    .padding(.horizontal, Constants.Spacing.md)
                    .padding(.vertical, 4)
                    .cornerRadiusBackground(with: Color.Background.primary, cornerRadius: 6, borderColor: Color.Component.Border.secondary)
                    .lineLimit(1)
            }
        }
    }
}

#Preview {
    ModelCardView(model: .mock, item: .init(modelInfo: .mock))
        .previewEnvironment()
}
