import Foundation

struct Constants {
    private init() {}

    struct Spacing {
        static let base: CGFloat = 8
        static let md: CGFloat = 12
        static let sm: CGFloat = 6
        private init() {}
    }

    static let SpaceMarginSM: CGFloat = 12
    static let SpaceMarginMarginXS: CGFloat = 8
    static let Radius200: CGFloat = 8
    static let ComponentsSelectGlobalControlPaddingHorizontal: CGFloat = 12
}

extension Constants {
    static let randomImage = "https://picsum.photos/600/600"
    static let discordUrl = URL(string: "https://discord.com/invite/nexa-ai")!
    static let githubUrl = URL(string: "https://github.com/NexaAI/nexa-sdk")!
    static let slackUrl = URL(string: "https://nexa-ai-community.slack.com/ssb/redirect")!
}
