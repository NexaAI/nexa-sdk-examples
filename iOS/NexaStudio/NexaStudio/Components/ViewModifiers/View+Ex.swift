
import SwiftUI

extension View {
    func backgroundWithRoundedRectangle(_ color: Color, _ cornerRadius: CGFloat = 0) -> some View {
        background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(color)
        )
    }

    func listBackground<S>(_ style: S, ignoresSafeAreaEdges edges: Edge.Set = .all) -> some View where S : ShapeStyle {
        scrollContentBackground(.hidden)
            .background(style, ignoresSafeAreaEdges: edges)
    }

    func removeListRowFormatting(_ insets: EdgeInsets = .zero) -> some View {
        self
            .listRowInsets(insets)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
    }

    func square(_ size: CGFloat) -> some View {
        self.frame(width: size, height: size)
    }

    @ViewBuilder
    func ifSatisfiedCondition(_ condition: Bool, transform: (Self) -> some View) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    func cornerRadiusBackground(
        with color: Color = Color.Background.primary,
        cornerRadius: CGFloat = 8,
        borderColor: Color = Color.Button.Tertiary.Border.default,
        borderWidth: CGFloat = 1
    ) -> some View {
        background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(color)
                .stroke(borderColor, lineWidth: borderWidth)
        )
    }

    func customNavigationBarTitle(
        _ title: String,
        titlePlacement: ToolbarItemPlacement = .principal,
        xOffset: CGFloat = 0,
        displayMode: NavigationBarItem.TitleDisplayMode = .inline
    ) -> some View {
        navigationBarTitleDisplayMode(displayMode)
            .toolbar {
            ToolbarItem(placement: titlePlacement) {
                Text(title)
                    .textStyle(.subtitle1())
                    .offset(x: xOffset)
            }
        }
    }

    func modalNavigationBar(
        _ title: String,
        titlePlacement: ToolbarItemPlacement = .topBarLeading,
        action: @escaping ( () -> Void )
    ) -> some View {
        toolbar {
            ToolbarItem(placement: titlePlacement) {
                Text(title)
                    .textStyle(.subtitle1())
            }
            ToolbarItem(placement: .topBarTrailing) {
                Image(.xmark)
                    .resizable()
                    .primaryStyle()
                    .square(24)
                    .padding(.horizontal, 12)
                    .offset(x: 12)
                    .contentShape(Rectangle())
                    .anyButton {
                        action()
                    }
            }
        }

    }

    func strokeButtonStyle() -> some View {
        textStyle(.body1(textColor: Color.Button.Secondary.Text.default))
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .cornerRadiusBackground(with: Color.Button.Secondary.Bg.default, cornerRadius: 18, borderColor: Color.Button.Secondary.Border.default)
            .contentShape(Rectangle())
    }

    func fillButtonStyle() -> some View {
        textStyle(.body1(textColor: Color.Button.Primary.Text.default))
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .cornerRadiusBackground(with: Color.Button.Primary.Bg.default, cornerRadius: 18, borderColor: Color.Button.Primary.Bg.default)
            .contentShape(Rectangle())
    }
}
