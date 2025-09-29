import SwiftUI

enum ToastType {
    case safe
    case success
    case error
}

struct AnyToast {
    var message: String
    var autoHidden: Bool
    var type: ToastType

    static func success(_ message: String) -> Self {
        AnyToast(message: message, autoHidden: true, type: .success)
    }

    static func safe(_ message: String) -> Self {
        AnyToast(message: message, autoHidden: true, type: .safe)
    }

    static func error(_ message: String) -> Self {
        AnyToast(message: message, autoHidden: true, type: .error)
    }
}

extension AnyToast {
    init(from error: Error) {
        self.autoHidden = true
        self.type = .error
        self.message = error.localizedDescription
    }
}

struct Toast: View {
    @Binding var isPresented: Bool

    var toast: AnyToast

    var body: some View {
        VStack {
            if isPresented {
                HStack(alignment: .center, spacing: 4) {
                    Image(.circleAlert)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(iconColor)
                        .square(16)
                    Text(toast.message)
                        .textStyle(.caption1(textColor: textColor))
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(8)
                .cornerRadiusBackground(with: bgColor, cornerRadius: 16, borderColor: borderColor)
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .onAppear {
                    if toast.autoHidden {
                        Task {
                            try? await Task.sleep(for: .seconds(2.5))
                            isPresented = false
                        }
                    }
                }
            }
        }
        .animation(.easeInOut, value: isPresented)
    }

    private var iconColor: Color {
        switch toast.type {
        case .safe:
            return Color.Safe.icon
        case .success:
           return Color.Success.icon
        case .error:
           return Color.Danger.icon
        }
    }

    private var textColor: Color {
        switch toast.type {
        case .safe:
            return Color.Safe.font
        case .success:
            return Color.Success.font
        case .error:
            return Color.Danger.font
        }
    }

    private var bgColor: Color {
        switch toast.type {
        case .safe:
            return Color.Safe.bg
        case .success:
            return Color.Success.bg
        case .error:
            return Color.Danger.bg
        }
    }

    private var borderColor: Color {
        switch toast.type {
        case .safe:
            return Color.Safe.bg
        case .success:
            return Color.Success.bg
        case .error:
            return Color.Danger.border
        }
    }

}

extension View {

    @ViewBuilder
    func toast(_ toast: Binding<AnyToast?>) -> some View {
        self
            .overlay(alignment: .top, content: {
                Toast(isPresented: Binding(toast), toast: toast.wrappedValue ?? .error(""))
                    .id(UUID())
            })
    }
}

#Preview {
    @Previewable @State var error: AnyToast?
    NavigationStack {
        ScrollView {
            VStack {
                Text("Click Me")
                    .onTapGesture {
                        error = AnyToast.error("error happen")
                    }
                Spacer()
            }
            .navigationTitle("ada")
        }
    }
    .toast($error)
}
