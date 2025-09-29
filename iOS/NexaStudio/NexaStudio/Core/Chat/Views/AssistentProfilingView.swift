import SwiftUI
import NexaAI

struct AssistentProfilingView: View {

    let message: Message
    var showAction: Bool = true

    var onVolumeButtonPress: ((Message) -> Void)?
    var onRegenerateButtonPress: ((Message) -> Void)?

    @State private var showMore: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if showAction {
                actionView
            }
            if let profile = message.profile {
                profillingView(profile)
                if showMore {
                    profillingMoreView(profile)
                }
            }

        }
        .animation(.smooth, value: showMore)
    }

    private var actionView: some View {
        HStack(spacing: 8) {
            Image(.copy)
                .primaryStyle()
                .frame(width: 24, height: 24)
                .contentShape(Rectangle())
                .anyButton {
                    UIDevice.impactOccurred(style: .light)
                    let content = message.partation.other.trimmingCharacters(in: .whitespacesAndNewlines)
                    UIPasteboard.general.string = content
                }
//            Image(.volume2)
//                .primaryStyle()
//                .frame(width: 24, height: 24)
//                .contentShape(Rectangle())
//                .anyButton {
//                    onVolumeButtonPress?(message)
//                }
            Image(.refreshCw)
                .primaryStyle()
                .frame(width: 24, height: 24)
                .contentShape(Rectangle())
                .anyButton {
                    UIDevice.impactOccurred(style: .light)
                    onRegenerateButtonPress?(message)
                }
        }
        .padding(.leading, 12)
    }

    @ViewBuilder
    private func profillingView(_ profileModel: ProfileModel) -> some View {
        HStack(spacing: 8) {
            Text("TTFT: \(String(format: "%.2f", Float(profileModel.ttft) / 1000_000.0)) s;")
            Text("Decode Speed: \(String(format: "%.2f", profileModel.speed)) t/s")
            Spacer()

            HStack(spacing: 4) {
                Text("More")
                Image(.chevronDown)
                    .resizable()
                    .tertiaryStyle()
                    .square(16)
                    .rotationEffect(showMore ? .degrees(180) :  .zero )
            }
            .anyButton {
                showMore.toggle()
            }
        }
        .padding(.vertical, 2)
        .padding(.leading, 12)
        .textStyle(.caption1(textColor: Color.Text.tertiary))
    }

    @ViewBuilder
    private func profillingMoreView(_ profileModel: ProfileModel) -> some View {
        let totalMemory = String(format: "%.02f", MemoryMonitor.totalDeviceMemory)
        let speed = String(format: "%.02f", profileModel.prefillSpeed)
        let peakMemoryPair = profileModel.peakMemoryPair
        let items: [(title: String, value: String, unit: String)] =
            [
                ("Acceleration", "\(profileModel.acceleration)", ""),
                ("Prefill Speed", "\(speed) ", " t/s"),
                ("Peak Memory", "\(peakMemoryPair.value) ", " \(peakMemoryPair.unit)/\(totalMemory)GB"),
            ]
        HStack(alignment: .center) {
            ForEach(0..<items.count, id: \.self) { idx in
                let item = items[idx]
                VStack(alignment: .leading, spacing: 0) {
                    Text(item.title)
                        .textStyle(.caption2(textColor: Color.Text.tertiary))

                    Text(item.value)
                        .textStyle(.body2(textColor: Color.Text.secondary))
                    +
                    Text(item.unit)
                        .textStyle(.caption2(textColor: Color.Text.tertiary))
                }
                if idx != items.count - 1 {
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.Component.Border.secondary, lineWidth: 1)
        )
    }
}

#Preview {
    VStack {
        AssistentProfilingView(message: .assistant("I am ai, who are u"), showAction: false)
        .padding(.leading, 16)
        .padding(.trailing, 16)

        AssistentProfilingView(message: .assistant("I am ai, who are u"), showAction: true)
        .padding(.leading, 16)
        .padding(.trailing, 16)
    }
}
