import SwiftUI

class ImageCache {
    static let shared = NSCache<NSString, UIImage>()

    static func loadImage(at url: URL) -> UIImage? {
        let key = url.path() as NSString
        if let cached = ImageCache.shared.object(forKey: key) {
            return cached
        }
        if let image = UIImage(contentsOfFile: url.path()) {
            ImageCache.shared.setObject(image, forKey: key)
            return image
        }
        return nil
    }
}

struct ChatUserBubbleView: View {
    let message: Message
    var onEditMenuPressed: (() -> Void)?
    @State private var selectedImageURL: URL?
    @State private var showPreview: Bool = false
    @State private var showMenu: Bool = false
    @State private var cacheImages: [String: UIImage] = .init()

    var body: some View {
        VStack(alignment: .trailing, spacing: 16) {
            if message.images.count == 1 {
                if let url = message.images.first,
                   let image = ImageCache.loadImage(at: url) {
                    let width = image.size.width
                    let height = image.size.height
                    let (iWidth, iHeight) = height > width ? (160.0, 240.0) : (240.0, 160.0)
                    HStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: iWidth, height: iHeight)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 12)
                            )
                            .anyButton {
                                selectedImageURL = url
                                showPreview = true
                            }
                    }
                    .frame(height: iHeight)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                }
            } else {
                ScrollView(.horizontal) {
                    HStack (spacing: 4) {
                        ForEach(message.images, id: \.self) { url in
                            if let image = ImageCache.loadImage(at: url) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .square(100)
                                    .clipShape(
                                        RoundedRectangle(cornerRadius: 16)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color(red: 0.08, green: 0.08, blue: 0.08).opacity(0.1), lineWidth: 1)

                                    )
                                    .onTapGesture {
                                        selectedImageURL = url
                                        showPreview = true
                                    }
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .defaultScrollAnchor(.trailing)
            }

            if let url = message.audios.first {
                AudioBubbleView(audioURL: url)
            }

            if !message.content.isEmpty {
                Text(message.content)
                    .textStyle(.body1(textColor: Color.Chatbox.font))
                    .multilineTextAlignment(.leading)
                    .padding(12)
                    .background(
                        UnevenRoundedRectangle(topLeadingRadius: 16, bottomLeadingRadius: 16, bottomTrailingRadius: 4, topTrailingRadius: 16, style: .continuous)
                            .fill(Color.Chatbox.bg)
                    )
                    .padding(.leading, 32)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .onLongPressGesture(perform: {
                        UIDevice.impactOccurred(style: .medium)
                        showMenu = true
                    })
                    .anyPopover(
                        isPresented: $showMenu,
                        position: .auto,
                        contentSize: .init(width: 250, height: 105)
                    ) {
                        MenuListView(items: [
                            .init(title: "Copy", icon: .copy, action: {
                                UIPasteboard.general.string = message.content.trimmingCharacters(in: .whitespacesAndNewlines)
                                showMenu = false
                            }),
                            .init(title: "Edit", icon: .pen, action: {
                                showMenu = false
                                onEditMenuPressed?()
                            })
                        ])
                        .frame(width: 250, height: 105)
                        .offset(x: 36)
                    }
            }
        }
        .fullScreenCover(isPresented: $showPreview) {
            selectedImageURL = nil
        } content: {
            ImagePreviewView(images: message.images, selectedImage: selectedImageURL)
        }
    }
}

#Preview {
    ChatUserBubbleView(message: .user("hello world"))
}
