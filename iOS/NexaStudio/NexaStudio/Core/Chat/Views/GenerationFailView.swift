import SwiftUI

struct GenerationFailView: View {

    var onRegenerateButtonPress: (() -> Void)?

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Image(.circleAlert)
                .resizable()
                .dangerStyle()
                .square(16)
                .padding(.trailing, 8)
            Text("Content generation failed—please try again.")
                .textStyle(.body2(textColor: Color.Danger.font))
                .lineLimit(2)

            Image(.refreshCw)
                .resizable()
                .primaryStyle()
                .square(16)
                .padding(.leading, 8)
                .padding(.trailing, 12)
                .contentShape(Rectangle())
                .anyButton {
                    onRegenerateButtonPress?()
                }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
    }
}

#Preview {
    GenerationFailView()
}
