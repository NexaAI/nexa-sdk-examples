import SwiftUI

struct CustomBackButtonViewModifier: ViewModifier {
    @Environment(\.dismiss) private var dismiss

    var backgButtonImage: ImageResource
    var onBackButtonPressed: ( () -> Bool )?

    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Image(backgButtonImage)
                        .resizable()
                        .primaryStyle()
                        .square(24)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .offset(x: -12)
                        .contentShape(Rectangle())
                        .anyButton {
                            let shouldDismiss = onBackButtonPressed?()
                            if shouldDismiss ?? true {
                                dismiss()
                            }
                        }
                }
            }
    }
}

extension View {
    func defaultBackButton(_ image: ImageResource = .arrowLeft, onBackButtonPressed: (()->Bool)? = nil) -> some View {
        modifier(CustomBackButtonViewModifier(backgButtonImage: image, onBackButtonPressed: onBackButtonPressed))
    }
}
