import SwiftUI

extension View {

    func shadow100(
        _ cornerRadius: CGFloat = 6,
        backgroundColor: Color = Color.Background.primary,
        strokeColor: Color = Color.Component.Border.secondary
    ) -> some View {
        self.background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(backgroundColor)
                .stroke(strokeColor, lineWidth: 1)
                .shadow(color: Color(red: 0.11, green: 0.31, blue: 0.33).opacity(0.16), radius: 3, x: 0, y: 1)
        )
    }

    func shadow200(
        _ cornerRadius: CGFloat = 6,
        backgroundColor: Color = Color.Background.primary,
        strokeColor: Color = Color.Component.Border.secondary
    ) -> some View {
        self.background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(backgroundColor)
                .stroke(strokeColor, lineWidth: 1)
                .shadow(color: Color(red: 0.11, green: 0.31, blue: 0.33).opacity(0.12), radius: 8, x: 0, y: 2)
        )
    }

    func shadow300(
        _ cornerRadius: CGFloat = 6,
        backgroundColor: Color = Color.Background.primary,
        strokeColor: Color = Color.Component.Border.secondary
    ) -> some View {
        self.background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(backgroundColor)
                .stroke(strokeColor, lineWidth: 1)
                .shadow(color: Color(red: 0.11, green: 0.31, blue: 0.33).opacity(0.15), radius: 3.5, x: 0, y: 2)
                .shadow(color: Color(red: 0.11, green: 0.31, blue: 0.33).opacity(0.08), radius: 8.5, x: 0, y: 5)
        )
    }

    func shadow400(
        _ cornerRadius: CGFloat = 6,
        backgroundColor: Color = Color.Background.primary,
        strokeColor: Color = Color.Component.Border.secondary
    ) -> some View {
        self.background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(backgroundColor)
                .stroke(strokeColor, lineWidth: 1)
                .shadow(color: Color(red: 0.11, green: 0.31, blue: 0.33).opacity(0.16), radius: 16, x: 0, y: 6)
                .shadow(color: Color(red: 0.09, green: 0.22, blue: 0.23).opacity(0.04), radius: 3, x: 0, y: 4)
        )
    }
}

extension Image {

    func primaryStyle() -> some View {
        renderingMode(.template)
            .foregroundStyle(Color.Icon.primary)
    }

    func brandStyle() -> some View {
        renderingMode(.template)
            .foregroundStyle(Color.Icon.brand)
    }

    func secondaryStyle() -> some View {
        renderingMode(.template)
            .foregroundStyle(Color.Icon.secondary)
    }

    func tertiaryStyle() -> some View {
        renderingMode(.template)
            .foregroundStyle(Color.Icon.tertiary)
    }

    func dangerStyle() -> some View {
        renderingMode(.template)
            .foregroundStyle(Color.Danger.icon)
    }

    func menuStyle() -> some View {
        renderingMode(.template)
            .foregroundStyle(Color.Menu.Icon.default)
    }

    func safeStyle() -> some View {
        renderingMode(.template)
            .foregroundStyle(Color.Safe.icon)
    }

    func buttonPrimaryStyle() -> some View {
        renderingMode(.template)
            .foregroundStyle(Color.Button.Primary.Icon.default)
    }
    func buttonSecondaryStyle() -> some View {
        renderingMode(.template)
            .foregroundStyle(Color.Button.Secondary.Icon.default)
    }

    func buttonDefaultStyle() -> some View {
        renderingMode(.template)
            .foregroundStyle(Color.Button.Default.Icon.default)
    }
}

#Preview {
    VStack {
        Text("abc")
            .textStyle(.largeTitle())
        +
        Text("ada")
            .textStyle(.body1())

        Text("Hello 100")
            .textStyle(.body1())
            .padding()
            .shadow100()

        Text("Hello 200")
            .textStyle(.body2())
            .padding()
            .shadow200()

        Text("Hello 300")
            .padding()
            .shadow300()

        Text("Hello 400")
            .padding()
            .shadow400()
    }
}
