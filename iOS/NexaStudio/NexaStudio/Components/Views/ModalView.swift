import SwiftUI

struct AnyModal {
    var backgroundColor: Color
    var content: () -> AnyView
    init(backgroundColor: Color = Color.Shader.op50, contentView: @escaping () -> AnyView) {
        self.backgroundColor = backgroundColor
        self.content = contentView
    }
}

struct ModalView<Content: View>: View {

    @Binding var showModal: Bool
    var backgroundColor: Color = Color.Shader.op50
    @ViewBuilder var content: Content
    var body: some View {
        ZStack {
            if showModal {
                Rectangle()
                    .fill(backgroundColor)
                    .ignoresSafeArea()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .blur(radius: 5)
                    .transition(.opacity)
                    .onTapGesture {
                        showModal = false
                    }
                    .zIndex(1)

                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .zIndex(2)
            }
        }
        .zIndex(9999)
        .animation(.easeInOut, value: showModal)
    }
}

extension View {

    func showModal(showModal: Binding<Bool>, backgroundColor: Color = Color.Shader.op50, @ViewBuilder content: () -> some View) -> some View {
        self
            .overlay(
                ModalView(showModal: showModal, backgroundColor: backgroundColor, content:  {
                    content()
                })
            )
    }

    @ViewBuilder
    func anyModal(_ modal: Binding<AnyModal?>) -> some View {
        self
            .overlay(
                ModalView(showModal: Binding(modal), backgroundColor: modal.wrappedValue?.backgroundColor ??  Color.Shader.op50, content:  {
                    modal.wrappedValue?.content() ?? AnyView(EmptyView())
                })
            )
    }
}

#Preview {
    @Previewable @State var showModel = false
    NavigationStack {
        VStack {
            Text("Click Me")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onTapGesture {
                    showModel.toggle()
                }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Button("Title") {

                }
            }
        }
    }
    .showModal(showModal: $showModel, backgroundColor: .red) {
        VStack {
            Text("Model View")
                .padding(40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onTapGesture {
            showModel = false
        }
        .transition(.move(edge: .leading))
    }
}
