import SwiftUI

struct GenerationSettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var path: [NavigationPathOption] = []
    @State var vm: GenerationSettingsViewModel

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 24) {
                        maxTokensView
                        if vm.isMultiModel {
                            Divider().frame(height: 1)
                                .background(Color.Stroke.primary)
                        }
                        sectionItem(title: "TopK", min: 1, max: 128, value: $vm.topK, formatter: NumberFormatter.intFormatter)
                        sectionItem(title: "TopP", min: 0, max: 1.0, value: $vm.topP, formatter: NumberFormatter.floatFormatter)
                        sectionItem(title: "Temprature", min: 0, max: 2.0, value: $vm.temprature, formatter: NumberFormatter.floatFormatter)

                        // acceleratorView

                        if vm.isMultiModel {
                            Divider().frame(height: 1)
                                .background(Color.Stroke.primary)
                            advanceView
                        } else {
                            systemPromptView
                        }
                    }
                    .padding(.vertical, 24)
                    .padding(.horizontal, 16)
                }
                .scrollContentBackground(.hidden)
                .scrollDismissesKeyboard(.immediately)
                .background(Color.Background.primary)
                .safeAreaInset(edge: .bottom) {
                    actionButtons
                }
            }
            .navigationDestinationForCoreModule(path: $path)
            .modalNavigationBar("Generation Settings") { dismiss() }
        }
    }

    private var advanceView: some View {
        HStack {
            Text("Advanced")
                .textStyle(.subtitle2())
            Spacer()
            Image(.chevronRight)
                .primaryStyle()
                .square(16)
        }
        .contentShape(Rectangle())
        .anyButton {
            path.append(.advanceSettingView)
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Spacer()
            Text("Reset")
                .strokeButtonStyle()
                .anyButton {
                    vm.reset()
                }

            HStack {
                Image(.check)
                    .resizable()
                    .buttonPrimaryStyle()
                    .square(16)
                Text("Save")
            }
            .fillButtonStyle()
            .anyButton {
                vm.save()
                dismiss()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.trailing, 16)
        .background(Color.Background.primary)
    }

    private var systemPromptView: some View {
        VStack(alignment: .leading) {
            Text("System Prompt")
                .textStyle(.subtitle2())
                .padding(.vertical, 12)
            TextEditor(text: $vm.systemPrompt)
                .textStyle(.body1(textColor: Color.Text.secondary))
                .frame(height: 135)
                .scrollContentBackground(.hidden)
                .background(
                    Text("Typing System Prompt...")
                        .textStyle(.body2(textColor: Color.Text.secondary))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .offset(x: 4, y: 10)
                        .opacity(vm.systemPrompt.isEmpty ? 1 : 0)
                )
                .padding(.vertical, 20)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.Component.Fills.primary)
                )
        }
    }

    private var acceleratorView: some View {
        VStack(alignment: .leading) {
            Text("Accelerator")
                .textStyle(.subtitle2())
                .padding(.vertical, 12)

            Picker("Accelerator", selection: $vm.acc) {
                ForEach(GenerationSettingsViewModel.Accelerator.allCases) { acc in
                    Text(acc.rawValue.uppercased())
                        .textStyle(.subtitle2())
                        .tag(acc)

                }
            }
            .pickerStyle(.segmented)
        }
    }

    private func sectionItem(title: String, min: Float, max: Float, value: Binding<Float>, formatter: Formatter) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .textStyle(.body2(textColor: Color.Text.secondary))
            HStack(spacing: 3) {
                SliderView(minimumValue: min, maximumValue: max, value: value)
                Spacer()
                TextField("", value: value, formatter: formatter)
                    .textStyle(.body2(textColor: Color.Input.Font.active))
                    .keyboardType(.decimalPad)
                    .frame(width: 80, height: 28)
                    .padding(.horizontal, 12)
                    .cornerRadiusBackground(with: Color.Input.Bg.default, cornerRadius: 8, borderColor: Color.Input.Border.default)
            }
            .padding(.vertical, 12)
        }
    }


    private var maxTokensView: some View {
        HStack {
            Text("Max Tokens")
                .textStyle(.subtitle2())
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            TextField("", value: $vm.maxTokens, formatter: NumberFormatter.intFormatter)
                .textStyle(.body2(textColor: Color.Input.Font.active))
                .keyboardType(.numberPad)
                .frame(width: 80, height: 28)
                .padding(.horizontal, 12)
                .cornerRadiusBackground(with: Color.Input.Bg.default, cornerRadius: 8, borderColor: Color.Input.Border.default)
        }
    }
}

#Preview {
    GenerationSettingsView(vm: .init(modelConfigManager: ModelConfigManager()))
        .previewEnvironment()
}
