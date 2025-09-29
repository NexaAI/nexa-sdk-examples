import SwiftUI

struct StatusView: View {

    struct Status {
        var image: ImageResource
        var imageColor: Color
        var background: Color
        var borderColor: Color
        var textColor: Color
        var message: String
        var actionTitle: String
        var action: (() -> Void)?
    }

    var status: Status

    var body: some View {
        VStack(spacing: 80) {
            Circle()
                .fill(status.background)
                .square(120)
                .overlay(alignment: .center) {
                    Image(status.image)
                        .resizable()
                        .renderingMode(.template)
                        .square(56)
                        .foregroundStyle(status.imageColor)
                }

            VStack(spacing: 24) {
                Text(status.message)
                    .textStyle(.body2(textColor: status.textColor))
                    .multilineTextAlignment(.center)
                Text(status.actionTitle)
                    .textStyle(.body1(textColor: Color.Button.Secondary.Text.default))
                    .padding(.vertical, 7)
                    .padding(.horizontal, 16)
                    .cornerRadiusBackground(with: Color.Button.Secondary.Bg.default, cornerRadius: 18, borderColor: Color.Button.Secondary.Border.default)
                    .anyButton {
                        status.action?()
                    }
            }
        }
        .padding(.horizontal, 55 + 16)
    }
}

extension StatusView.Status {
    static func network(_ message: String = "No connection right now, please reconnect.", action: @escaping (() -> Void)) -> Self {
        Self.init(image: .cloudAlert, imageColor: Color.Warning.icon, background: Color.Warning.bg, borderColor: Color.Warning.border, textColor: Color.Warning.font, message: message, actionTitle: "Refresh", action: action)
    }

    static func modelLoad(_ message: String = "Model couldn’t be loaded, please try again or choose another one.", action: @escaping (() -> Void)) -> Self {
        Self.init(image: .gridX, imageColor: Color.Warning.icon, background: Color.Warning.bg, borderColor: Color.Warning.border, textColor: Color.Warning.font, message: message, actionTitle: "Try Again", action: action)
    }

    static func other(_ message: String, action: @escaping (() -> Void)) -> Self {
        Self.init(image: .octagonAlert, imageColor: Color.Danger.icon, background: Color.Danger.bg, borderColor: Color.Danger.border, textColor: Color.Danger.font, message: message, actionTitle: "Try Again", action: action)
    }
}

#Preview {
    VStack {
        StatusView(status: .modelLoad(action: {
            print("network")
        }))
    }

}
