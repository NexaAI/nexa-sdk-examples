
import SwiftUI

struct ModelSectionHeaderView: View {

    @State private var isExpand: Bool = true

    let modelType: ModelType
    var onChevronDownPressed: (() -> Void)?

    var body: some View {
        HStack(spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                Image(modelType.imageResource)
                    .resizable()
                    .square(24)
                Text(modelType.title)
                    .textStyle(.body1())
            }

            Spacer()
            Image(.chevronDown)
                .resizable()
                .primaryStyle()
                .square(24)
                .rotationEffect(.degrees(isExpand ? 0 : -90))
                .anyButton {
                    isExpand.toggle()
                    onChevronDownPressed?()
                }
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .animation(.smooth, value: isExpand)
    }
}

#Preview {
    VStack(spacing: 8) {
        ModelSectionHeaderView(modelType: .imageToText)
        ModelSectionHeaderView(modelType: .chat)
    }

}
