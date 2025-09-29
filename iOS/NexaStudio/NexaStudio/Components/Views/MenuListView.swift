import SwiftUI
import Foundation

struct MenuItem: Identifiable {
    let id = UUID().uuidString
    let title: String
    let icon: ImageResource
    let action: (() -> Void)?
}

struct MenuItemView: View {
    let title: String
    let icon: ImageResource
    var body: some View {
        HStack {
            Text(title)
                .textStyle(.body1(textColor: Color.Menu.Font.default))
            Spacer()
            Image(icon)
                .renderingMode(.template)
                .resizable()
                .square(24)
                .foregroundStyle(Color.Menu.Icon.default)
        }
        .padding(12)
    }
}

struct MenuListView: View {
    let items: [MenuItem]

    var body: some View {
        VStack {
            ForEach(items) { item in
                MenuItemView(title: item.title, icon: item.icon)
                .contentShape(Rectangle())
                .anyButton(.background) {
                    item.action?()
                }
            }
        }
        .padding(4)
        .shadow400(8, backgroundColor: Color.Menu.Bg.default, strokeColor: Color.Menu.Border.default)
    }
}

#Preview {
    VStack {
        MenuListView(items: [.init(title: "aca", icon: .arrowDown) {

        }, .init(title: "def", icon: .arrowLeft) {

        }])
    }
}
