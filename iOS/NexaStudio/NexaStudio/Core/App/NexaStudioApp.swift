
import SwiftUI
import AVFoundation
import NexaAI

@main
struct NexaStudioApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @AppStorage(AppStoreKey.colorTheme)
    private var appTheme: AppTheme = .system

    var body: some Scene {
        WindowGroup {
            AnyAlertContainer {
                ChatView(
                    vm: .init(
                        conversationManager: delegate.dependencies.conversationManager,
                        modelManager: delegate.dependencies.modelManager
                    )
                )
                .environment(delegate.dependencies.conversationManager)
                .environment(delegate.dependencies.modelManager)
                .environment(delegate.dependencies.modelDownloadManager)
                .dynamicTypeSize(.medium)
                .preferredColorScheme(appTheme.colorScheme)
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    var dependencies: Dependencies!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {

        NexaSdk.install()

        appearance()
        setupAudioSessionForPlayback()

        dependencies = Dependencies()

        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { _ in
            Log.warn("Receive Memory Warning")
        }
        return true
    }

    func appearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.Background.primary
        appearance.shadowColor = UIColor.Stroke.secondary

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance

        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor.Tab.Bg.active
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.foregroundColor: UIColor.Tab.Font.active], for: .selected
        )
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.foregroundColor: UIColor.Tab.Font.default], for: .normal)

        UIProgressView.appearance().tintColor = UIColor.Progress.bgProgress
        UIProgressView.appearance().progressTintColor = UIColor.Progress.bgProgress
        UIProgressView.appearance().trackTintColor = .clear
    }

    func setupAudioSessionForPlayback() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.interruptSpokenAudioAndMixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch { }
    }
}

@MainActor
struct Dependencies {
    let conversationManager: ConversationManager
    let modelManager: ModelManager
    let modelDownloadManager: ModelDownloadManager
    let modelConfigManager: ModelConfigManager
    init() {
        conversationManager = ConversationManager(persistence: LocalConversationPersistence())
        modelConfigManager = ModelConfigManager()

        let modelPersistence = LocalFileModelPersistence()
        modelManager = ModelManager(modelConfigManager: modelConfigManager, modelPersistence: modelPersistence)
        modelDownloadManager = ModelDownloadManager(modelPersistence: modelPersistence)
    }
}

@MainActor
class DevPreview {
    static let share = DevPreview()
    let conversationManager: ConversationManager
    let modelManager: ModelManager
    let modelDownloadManager: ModelDownloadManager
    init() {
        conversationManager = ConversationManager(persistence: MockConversationPersistence())
        let modelPersistence = LocalFileModelPersistence()
        modelManager = ModelManager(model: MockModel(), modelConfigManager: ModelConfigManager(), modelPersistence: modelPersistence)
        modelDownloadManager = ModelDownloadManager(modelPersistence: modelPersistence)
    }
}

extension View {
    func previewEnvironment() -> some View {
        self
            .environment(DevPreview.share.conversationManager)
            .environment(DevPreview.share.modelManager)
            .environment(DevPreview.share.modelDownloadManager)
    }
}
