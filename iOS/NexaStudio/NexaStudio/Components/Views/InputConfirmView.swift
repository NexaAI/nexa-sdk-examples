import SwiftUI

struct InputConfirmView: View {
    var title: String = ""
    var prompt: String = ""
    var enableEmpty: Bool = true
    @State var value: String = ""
    @FocusState private var isFocused: Bool

    var onConfirm: ((String) -> Void)?
    var onClose: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                Text(title)
                    .textStyle(.subtitle1())
                Spacer()
                Image(.x)
                    .resizable()
                    .primaryStyle()
                    .square(24)
                    .anyButton {
                        onClose?()
                    }
            }
            .padding(.vertical, 12)

            TextField(
                "",
                text: $value,
                prompt: Text(prompt).textStyle(.body1(textColor: Color.Input.Font.default)),
                axis: .vertical
            )
            .textStyle(.body2(textColor: Color.Input.Font.active))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .cornerRadiusBackground(with: Color.Input.Bg.default, cornerRadius: 8, borderColor: Color.Input.Border.default)
            .padding(.vertical, 12)
            .focused($isFocused)

            Text("Confirm")
                .textStyle(.body1(textColor: disableConfirm ? Color.Button.Primary.Text.disabled : Color.Button.Primary.Text.default))
                .padding(.vertical, 7)
                .padding(.horizontal, 16)
                .cornerRadiusBackground(with: disableConfirm ? Color.Button.Primary.Bg.disabled : Color.Button.Primary.Bg.default, borderColor: .clear)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .contentShape(Rectangle())
                .anyButton {
                    onConfirm?(value)
                }
                .disabled(disableConfirm)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
        .shadow400(16, backgroundColor: Color.Popover.bg, strokeColor: .clear)
        .padding(.horizontal, 50)
        .onAppear {
            Task {
                try? await Task.sleep(for: .seconds(0.2))
                self.isFocused = true
            }
        }
    }

    private var disableConfirm: Bool {
        !enableEmpty && value.isEmpty
    }
}

struct AnyInputConfirm {
    var title: String = ""
    var prompt: String = ""
    var value: String = ""
    var enableEmpty: Bool = true
    var onConfirm: ((String) -> Void)?
}

extension View {
    @ViewBuilder
    func anyInputConfirm(_ confirm: Binding<AnyInputConfirm?>) -> some View {
        modifier(InputConfirmViewModifier(inputModel: confirm))
    }
}

struct InputConfirmViewModifier: ViewModifier {

    @Binding var inputModel: AnyInputConfirm?

    func body(content: Content) -> some View {
        content.showModal(showModal: Binding($inputModel)) {
            InputConfirmView(
                title: inputModel?.title ?? "",
                prompt: inputModel?.prompt ?? "",
                enableEmpty: inputModel?.enableEmpty ?? true,
                value: inputModel?.value ?? ""
            ) { value in
                inputModel?.onConfirm?(value)
                inputModel = nil
            } onClose: {
                inputModel = nil
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .offset(y: -50)
            .transition(.move(edge: .bottom))
        }
    }
}

#Preview {
    InputConfirmView(title: "Rename Chat", prompt: "Input title", value: "ada")
}
