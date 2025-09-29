import SwiftUI

struct ChatModelSelectView: View {

    var showModelSelectedView: Bool = false
    var insets: EdgeInsets = .zero
    
    var onSelectModelButtonPressed: (() -> Void)?

    @State var keyboardHeight: CGFloat = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            ExplorePlaceholderView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .offset(y: (insets.bottom - insets.top) / 2)
                .offset(y: -keyboardHeight / 3 - 52 )
            if showModelSelectedView {
                VStack(spacing: 12) {
                    Text("Select Model")
                        .textStyle(.body1(textColor: Color.Button.Secondary.Text.default))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.Button.Secondary.Bg.default)
                                .stroke(Color.Button.Secondary.Border.default, lineWidth: 1)
                        )
                        .anyButton {
                            onSelectModelButtonPressed?()
                        }

                    Label {
                        Text("No Model Selected")
                            .textStyle(.caption1(textColor: .gray6))
                    } icon: {
                        Image(.info)
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(.gray6)
                    }
                }
                .padding(.bottom, 60)
            }

        }
        .keyboardHeight($keyboardHeight)
        .animation(.smooth, value: keyboardHeight)
    }
}

struct ExplorePlaceholderView: View {
    var body: some View {
        HStack {
            ZStack(alignment: .leading) {
                Image(.circleBackground)
                    .resizable()
                    .frame(width: 185, height: 185)

                HStack(spacing: 10) {
                    Image(.nexa)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 105, height: 26)
                    Image(.studio)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 147, height: 26)
                }
                .padding(.leading, 102)
            }
            .frame(width: 364)
            .offset(x: -16)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

#Preview {
    ExplorePlaceholderView()
}

#Preview {
    VStack {
        GeometryReader { geo in
            ChatModelSelectView {

            }
            .frame(height: UIScreen.main.bounds.height - geo.safeAreaInsets.top - geo.safeAreaInsets.bottom)
        }
    }
}
