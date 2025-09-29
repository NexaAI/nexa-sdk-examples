
import SwiftUI

struct ChatModelListView: View {

    static let itemHeight = 48.0
    static let moreButtonHeight = 36.0

    var models: [ModelInfo] = []
    var selectedModel: ModelInfo?

    var onSelectedModel: ((ModelInfo)-> Void)?
    var onMoreButtonPress: (() -> Void)?

    var body: some View {
        VStack(spacing: 1) {
            ForEach(models) { model in
                HStack(alignment: .center, spacing: 8) {
                    Image(model.modelType.imageResource)
                        .resizable()
                        .square(24)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(model.name)
                            .textStyle(.caption2(textColor: Color.Menu.Font.default))
                            .lineLimit(1)
                        Text(model.modelType.title)
                            .textStyle(.caption2(textColor: Color.Menu.Font.detail))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                    if model == selectedModel {
                        Image(.check)
                            .menuStyle()
                            .square(16)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .contentShape(Rectangle())
                .anyButton {
                    onSelectedModel?(model)
                }
                .frame(height: Self.itemHeight)
            }
            Divider()
                .frame(height: 1)
                .background(Color.Component.Border.secondary)

            HStack(spacing: 4) {
                Text("More Models")
                    .textStyle(.caption1(textColor: Color.Text.primary))
                Image(.arrowRight)
                    .resizable()
                    .primaryStyle()
                    .square(16)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
            .anyButton {
                onMoreButtonPress?()
            }
            .frame(height: Self.moreButtonHeight)
        }
        .padding(4)
        .shadow300(backgroundColor: Color.Menu.Bg.default, strokeColor: Color.Menu.Border.default)
    }
}

#Preview {
    ChatModelListView(models: [.mock, .mockVLM], selectedModel: .mock) { _ in

    } onMoreButtonPress: {

    }
    .padding()

}
