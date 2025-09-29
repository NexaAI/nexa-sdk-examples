import SwiftUI

struct SegmentedPicker<ID: Hashable & CustomStringConvertible>: View {

    var items: [ID]
    @Binding var selected: ID

    var itemActiveForegroundColor: Color = Color.Tab.Font.active
    var itemInactiveForegroundColor: Color = Color.Tab.Font.default

    var activeItemBackgroundColor: Color = Color.Tab.Bg.active
    var activeitemBackgroundCornerRadius: CGFloat = 8

    var backgroundCornerRadius: CGFloat = 8
    var backgroundColor: Color = Color.Tab.Bg.default

    @Namespace private var namespace
    
    var body: some View {
        HStack {
            ForEach(items, id: \.self) { item in
                ZStack {
                    if item == selected {
                        Rectangle()
                            .fill(.clear)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .frame(maxWidth: .infinity)
                            .background(RoundedRectangle(cornerRadius: activeitemBackgroundCornerRadius)
                                .fill(activeItemBackgroundColor))
                            .matchedGeometryEffect(id: "background", in: namespace)
                    }
                    Text(item.description)
                        .textStyle(.subtitle2(textColor: item == selected ? itemActiveForegroundColor : itemInactiveForegroundColor))
                        .animation(nil)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .frame(maxWidth: .infinity)
                }
                .onTapGesture {
                    selected = item
                }
            }
        }
        .animation(.easeInOut, value: selected)
        .padding(.vertical, 4)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: backgroundCornerRadius)
                .fill(backgroundColor)
        )
    }
}

#Preview {
    @Previewable @State var selected: String = "Dark"
    VStack {
        SegmentedPicker(items: ["Auto", "Light", "Dark"], selected: $selected)
    }
}
