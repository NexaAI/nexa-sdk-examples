
import SwiftUI
import Foundation

enum Router {
    static func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

enum NavigationPathOption: Hashable {
    case chatView(conversationId: String)
    case modelListView
    case advanceSettingView
    case appSettingView
}

struct NavDestForCoreModuleViewModifier: ViewModifier {

    @Environment(ConversationManager.self) private var conversationManager
    @Environment(ModelManager.self) private var modelManager
    @Environment(ModelDownloadManager.self) private var modelDownloadManager

    let path: Binding<[NavigationPathOption]>

    func body(content: Content) -> some View {
        content
            .navigationDestination(for: NavigationPathOption.self) { newValue in
                switch newValue {
                case .chatView(let conversationId):
                    ChatView(
                        vm: .init(
                            conversationManager: conversationManager,
                            modelManager: modelManager,
                            conversationId: conversationId
                        )
                    )
                case .modelListView:
                    ModelListView(vm: .init(downloadManager: modelDownloadManager, modelManager: modelManager))
                case .advanceSettingView:
                    AdvanceSettingView(vm: .init(modelConfigManager: modelManager.configManager))
                case .appSettingView:
                    AppSettingView()
                }
            }
    }
}

extension View {
    
    func navigationDestinationForCoreModule(path: Binding<[NavigationPathOption]>) -> some View {
        modifier(NavDestForCoreModuleViewModifier(path: path))
    }
}
