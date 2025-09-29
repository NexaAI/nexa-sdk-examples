import SwiftUI

struct AppSettingView: View {

    @AppStorage(AppStoreKey.colorTheme)
    private var appTheme: AppTheme = .system

    @AppStorage(AppStoreKey.offloadWhenEnterBackground)
    private var offloadWhenEnterBackground: Bool = true

    private let allContextLength = [1024, 2048, 4096]

    @Environment(ModelManager.self) private var modelManager
    @Environment(\.dismiss) private var dismiss

    var onCloseButtonPressed: (() -> Void)?

    func reset() {
        offloadWhenEnterBackground = true
        appTheme = .system
        modelManager.configManager.contextLength = ModelConfigManager.defaultContextLength
        modelManager.configManager.isThinkModeOn = true
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
//                themeSettingView
//                    .padding(.top, 20)
//                    .padding(.bottom, 12)
//
//                SeparatorView()
//                    .padding(.vertical, 12)
//                Text("Model")
//                    .textStyle(.subtitle2())
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(.vertical, 12)

//                enableEmbedingView
//                    .padding(.vertical, 18)

                thinkModeView
                    .padding(.vertical, 18)

                loadSettingView
                    .padding(.vertical, 12)

                contextLengthSettingView
                    .padding(.vertical, 12)
            }
            .padding(.horizontal, 16)

        }
        .navigationBarBackButtonHidden()
        .modalNavigationBar("Settings") { dismiss() }
        .listBackground(Color.Background.primary)
        .safeAreaInset(edge: .bottom) {
            actionButtons
        }
    }

    private var enableEmbedingView: some View {
        HStack {
            Text("Enable Retrieval Augmented")
                .textStyle(.subtitle2())
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .trailing) {
            Toggle("", isOn: Binding(get: {
                modelManager.configManager.isEmbedOn
            }, set: { newValue in
                modelManager.configManager.isEmbedOn = newValue
            }))
            .tint(.brand7)
        }
    }

    private var thinkModeView: some View {
        HStack {
            Text("Thinking Mode")
                .textStyle(.subtitle2())
            Spacer()
            Toggle("", isOn: Binding(get: {
                modelManager.configManager.isThinkModeOn
            }, set: { newValue in
                modelManager.configManager.isThinkModeOn = newValue
            }))
            .tint(.brand7)
        }
    }

    private var themeSettingView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Theme")
                .textStyle(.subtitle2())
                .frame(maxWidth: .infinity, alignment: .leading)

            SegmentedPicker(items: AppTheme.allCases, selected: $appTheme)
        }
    }

    private var contextLengthSettingView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("N_CTX")
                .textStyle(.subtitle2())
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("Total tokens that model keep in context window at once.")
                .textStyle(.caption2(textColor: Color.Text.tertiary))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)

            SegmentedPicker(items: allContextLength, selected: Binding<Int>(get: {
                modelManager.configManager.contextLength
            }, set: { newValue in
                modelManager.configManager.contextLength = newValue
            }))
            .padding(.top, 12)
        }
    }

    private var loadSettingView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Auto Unload/Load")
                .textStyle(.subtitle2())
            Text("Frees RAM when idle; reload model on reopen.")
                .lineLimit(2)
                .textStyle(.caption2(textColor: Color.Text.tertiary))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay {
            Toggle("",isOn: $offloadWhenEnterBackground)
                .tint(.brand7)
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Spacer()
            Text("Reset")
                .strokeButtonStyle()
                .anyButton {
                    reset()
                }
            Text("Close")
            .fillButtonStyle()
            .anyButton {
                dismiss()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.trailing, 16)
        .background(Color.Background.primary)
    }
}

#Preview {
    AppSettingView()
}
