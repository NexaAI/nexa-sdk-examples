import SwiftUI

struct AdvanceSettingView: View {
    @Environment(\.dismiss) private var dismiss

    @State var vm: AdvanceSettingViewModel

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    sectionItem(title: "Min Probability", min: 0.0, max: 1.0, value: $vm.minProbability, formatter: NumberFormatter.floatFormatter)
                    sectionItem(title: "XTC Threshold", min: 0.0, max: 1.0, value: $vm.tcThreshold, formatter: NumberFormatter.floatFormatter)
                    sectionItem(title: "XTC Probability", min: 0.0, max: 1.0, value: $vm.xtcProbability, formatter: NumberFormatter.floatFormatter)
                    sectionItem(title: "Typical P", min: 0.0, max: 2.0, value: $vm.typicalP, formatter: NumberFormatter.floatFormatter)

                    Divider().frame(height: 1).background(Color.Stroke.primary)

                    sectionItem(title: "Penalty Last_N", min: 0, max: 256, value: $vm.penaltyLastN, formatter: NumberFormatter.intFormatter)
                    sectionItem(title: "Penalty Present", min: 0.0, max: 2.0, value: $vm.penaltyPresent, formatter: NumberFormatter.floatFormatter)

                    Divider().frame(height: 1).background(Color.Stroke.primary)
                    mirostatSection
                    seedSection
                    jinjaSection
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 16)
            }
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.immediately)
            .background(Color.Background.primary)
            .safeAreaInset(edge: .bottom) {
                actionButtons
            }
        }
        .customNavigationBarTitle(
            "Generation Settings",
            titlePlacement: .topBarLeading,
            xOffset: -20
        )
        .defaultBackButton()
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

    private var jinjaSection: some View {
        HStack {
            Text("Jinja")
                .textStyle(.subtitle2())
            Spacer()
            Toggle("", isOn: $vm.isJinja)
                .tint(.brand7)
        }
        .padding(.vertical, 5)
    }

    private var seedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Seed")
                .textStyle(.subtitle2())
            TextField("", value: $vm.seed, formatter: NumberFormatter.intFormatter)
                .textStyle(.body2(textColor: Color.Input.Font.active))
                .keyboardType(.decimalPad)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .cornerRadiusBackground(with: Color.Input.Bg.default, cornerRadius: 8, borderColor: Color.Input.Border.default)
        }
        .frame(maxWidth: .infinity)
    }

    private var mirostatSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mirostat")
                .textStyle(.subtitle2())

            Picker("Accelerator", selection: $vm.mirostat) {
                ForEach(AdvanceSettingViewModel.Mirostat.allCases) { mirostat in
                    Text(mirostat.rawValue.uppercased())
                        .textStyle(.subtitle2())
                        .tag(mirostat)
                }
            }
            .pickerStyle(.segmented)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
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
}

#Preview {
    AdvanceSettingView(vm: .init(modelConfigManager: ModelConfigManager()))
        .previewEnvironment()
}
